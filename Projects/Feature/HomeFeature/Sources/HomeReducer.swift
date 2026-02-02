import Foundation
import Rex
import HomeFeatureInterface
import MemosDomainInterface
import UsersDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import NotificationCoreInterface
import Localization
import BaseFeature

public struct HomeReducer: Reducer {
    private let memosUseCase: MemosUseCase
    private let usersUseCase: UsersUseCase
    private let alarmsUseCase: AlarmsUseCase
    private let schedulesUseCase: SchedulesUseCase
    private let alarmSchedulesUseCase: AlarmSchedulesUseCase
    private let notificationService: NotificationService
    private let dateProvider: () -> Date
    private let calendar = Calendar.current
    
    public init(
        memosUseCase: MemosUseCase,
        usersUseCase: UsersUseCase,
        alarmsUseCase: AlarmsUseCase,
        schedulesUseCase: SchedulesUseCase,
        alarmSchedulesUseCase: AlarmSchedulesUseCase,
        notificationService: NotificationService,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.memosUseCase = memosUseCase
        self.usersUseCase = usersUseCase
        self.alarmsUseCase = alarmsUseCase
        self.schedulesUseCase = schedulesUseCase
        self.alarmSchedulesUseCase = alarmSchedulesUseCase
        self.notificationService = notificationService
        self.dateProvider = dateProvider
    }
    
    public func reduce(state: inout HomeState, action: HomeAction) -> [Effect<HomeAction>] {
        switch action {
        case .viewAppear:
            let today = dateProvider()
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: today)
            // 초기 로드시에만 currentDisplayDate를 오늘로 설정
            if state.currentDisplayDate == Date() || calendar.isDate(state.currentDisplayDate, inSameDayAs: Date.distantPast) {
                state.currentDisplayDate = todayStart
            }
            state.homeTitle = today.toString()
            return [.just(.loadHomeData)]
            
        case .loadHomeData:
            state.isLoading = true
            return [
                Effect { [self] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            emitter.send(.setLoading(false))
                            return
                        }
                        
                        async let memosTask = memosUseCase.getMemos(userId: user.id)
                        async let alarmsTask = alarmsUseCase.fetchAll(userId: user.id)
                        async let schedulesTask = schedulesUseCase.getSchedules(userId: user.id)
                        
                        let memos = try await memosTask
                        let alarms = try await alarmsTask
                        let schedules = try await schedulesTask
                        let wakeDuration: Int? = nil
                        
                        emitter.send(.setHomeData(
                            wakeDuration: wakeDuration,
                            memos: memos,
                            alarms: alarms,
                            schedules: schedules
                        ))
                    } catch {
                        emitter.send(.setLoading(false))
                    }
                }
            ]
            
        case let .setHomeData(wakeDuration, memos, alarms, schedules):
            state.isLoading = false
            
            // 중복 제거
            let uniqueMemos = Array(Set(memos.map { $0.id })).compactMap { id in memos.first { $0.id == id } }
            let uniqueAlarms = Array(Set(alarms.map { $0.id })).compactMap { id in alarms.first { $0.id == id } }
            let uniqueSchedules = Array(Set(schedules.map { $0.id })).compactMap { id in schedules.first { $0.id == id } }
            
            state.allMemos = uniqueMemos.sorted(by: reminderSortPredicate)
            state.alarms = uniqueAlarms.sorted { $0.time < $1.time }
            state.schedules = uniqueSchedules
            // homeTitle은 현재 표시 중인 날짜로 업데이트 (오늘이 아닐 수도 있음)
            state.homeTitle = state.currentDisplayDate.toString()
            
            // currentDisplayDate는 변경하지 않음
            // - 초기 로드는 viewAppear에서 처리
            // - 사용자가 선택한 날짜는 유지되어야 함
            // - appendNextDayData/prependPreviousDayData에서만 변경
            
            // 활성화된 알람을 AlarmKit에 등록 (로그인 시 복원)
            let enabledAlarms = uniqueAlarms.filter { $0.isEnabled }
            for alarm in enabledAlarms {
                Task {
                    try? await alarmSchedulesUseCase.scheduleAlarm(alarm)
                }
            }
            
            // 미래 스케줄만 필터링하여 notification 등록
            let now = Date()
            let futureSchedules = uniqueSchedules.filter { schedule in
                // 스케줄 날짜와 시작 시간 파싱
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = calendar.timeZone
                
                guard let scheduleDate = dateFormatter.date(from: schedule.date) else {
                    return false
                }
                
                // 시작 시간 파싱 (HH:mm 또는 HH:mm:ss 형식)
                let timeComponents = schedule.startTime.split(separator: ":").compactMap { Int($0) }
                guard timeComponents.count >= 2 else {
                    return false
                }
                
                let hour = timeComponents[0]
                let minute = timeComponents[1]
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: scheduleDate)
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0
                
                guard let scheduleDateTime = calendar.date(from: dateComponents) else {
                    return false
                }
                
                // 미래 스케줄만 포함
                return scheduleDateTime > now
            }
            
            // 스케줄 notification 등록 (미래 스케줄만)
            return [
                Effect { [notificationService, futureSchedules] _ in
                    await notificationService.scheduleNotifications(for: futureSchedules)
                }
            ]
            
        case .loadNextDayData:
            guard !state.isLoadingNextDay else { return [] }
            state.isLoadingNextDay = true
            let nextDay = calendar.date(byAdding: .day, value: 1, to: state.currentDisplayDate) ?? state.currentDisplayDate
            
            return [
                Effect { [self, nextDay] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            emitter.send(.setLoadingNextDay(false))
                            return
                        }
                        
                        let targetDateString = formatDateString(nextDay)
                        
                        // 다음날의 알람, 스케줄, 메모 가져오기
                        let allMemos = try await memosUseCase.getMemos(userId: user.id)
                        let allAlarms = try await alarmsUseCase.fetchAll(userId: user.id)
                        let allSchedules = try await schedulesUseCase.getSchedules(userId: user.id)
                        
                        let nextDayMemos = allMemos.filter { memo in
                            guard let createdAt = memo.createdAt else { return false }
                            return calendar.isDate(createdAt, inSameDayAs: nextDay)
                        }
                        
                        let nextDayWeekday = calendar.component(.weekday, from: nextDay) - 1
                        let nextDayAlarms = allAlarms.filter { alarm in
                            if alarm.repeatDays.isEmpty {
                                return false
                            } else {
                                return alarm.isEnabled && alarm.repeatDays.contains(nextDayWeekday)
                            }
                        }
                        
                        let nextDaySchedules = allSchedules.filter { schedule in
                            schedule.date == targetDateString
                        }
                        
                        emitter.send(.appendNextDayData(
                            memos: nextDayMemos,
                            alarms: nextDayAlarms,
                            schedules: nextDaySchedules
                        ))
                    } catch {
                        emitter.send(.setLoadingNextDay(false))
                    }
                }
            ]
            
        case let .appendNextDayData(memos, alarms, schedules):
            state.isLoadingNextDay = false
            
            // 중복 제거: 이미 존재하는 아이템은 추가하지 않음
            let existingMemoIds = Set(state.allMemos.map { $0.id })
            let newMemos = memos.filter { !existingMemoIds.contains($0.id) }
            state.allMemos.append(contentsOf: newMemos)
            state.allMemos = state.allMemos.sorted(by: reminderSortPredicate)
            
            let existingAlarmIds = Set(state.alarms.map { $0.id })
            let newAlarms = alarms.filter { !existingAlarmIds.contains($0.id) }
            state.alarms.append(contentsOf: newAlarms)
            state.alarms = state.alarms.sorted { $0.time < $1.time }
            
            let existingScheduleIds = Set(state.schedules.map { $0.id })
            let newSchedules = schedules.filter { !existingScheduleIds.contains($0.id) }
            state.schedules.append(contentsOf: newSchedules)
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: state.currentDisplayDate) {
                state.currentDisplayDate = nextDay
            }
            return []
            
        case .loadPreviousDayData:
            guard !state.isLoadingNextDay else { return [] }
            state.isLoadingNextDay = true
            let previousDay = calendar.date(byAdding: .day, value: -1, to: state.currentDisplayDate) ?? state.currentDisplayDate
            
            return [
                Effect { [self, previousDay] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            emitter.send(.setLoadingNextDay(false))
                            return
                        }
                        
                        let targetDateString = formatDateString(previousDay)
                        
                        // 전날의 알람, 스케줄, 메모 가져오기
                        let allMemos = try await memosUseCase.getMemos(userId: user.id)
                        let allAlarms = try await alarmsUseCase.fetchAll(userId: user.id)
                        let allSchedules = try await schedulesUseCase.getSchedules(userId: user.id)
                        
                        let previousDayMemos = allMemos.filter { memo in
                            guard let createdAt = memo.createdAt else { return false }
                            return calendar.isDate(createdAt, inSameDayAs: previousDay)
                        }
                        
                        let previousDayWeekday = calendar.component(.weekday, from: previousDay) - 1
                        let previousDayAlarms = allAlarms.filter { alarm in
                            if alarm.repeatDays.isEmpty {
                                return false
                            } else {
                                return alarm.isEnabled && alarm.repeatDays.contains(previousDayWeekday)
                            }
                        }
                        
                        let previousDaySchedules = allSchedules.filter { schedule in
                            schedule.date == targetDateString
                        }
                        
                        emitter.send(.prependPreviousDayData(
                            memos: previousDayMemos,
                            alarms: previousDayAlarms,
                            schedules: previousDaySchedules
                        ))
                    } catch {
                        emitter.send(.setLoadingNextDay(false))
                    }
                }
            ]
            
        case let .prependPreviousDayData(memos, alarms, schedules):
            state.isLoadingNextDay = false
            
            // 중복 제거: 이미 존재하는 아이템은 추가하지 않음
            let existingMemoIds = Set(state.allMemos.map { $0.id })
            let newMemos = memos.filter { !existingMemoIds.contains($0.id) }
            state.allMemos.insert(contentsOf: newMemos, at: 0)
            state.allMemos = state.allMemos.sorted(by: reminderSortPredicate)
            
            let existingAlarmIds = Set(state.alarms.map { $0.id })
            let newAlarms = alarms.filter { !existingAlarmIds.contains($0.id) }
            state.alarms.insert(contentsOf: newAlarms, at: 0)
            state.alarms = state.alarms.sorted { $0.time < $1.time }
            
            let existingScheduleIds = Set(state.schedules.map { $0.id })
            let newSchedules = schedules.filter { !existingScheduleIds.contains($0.id) }
            state.schedules.insert(contentsOf: newSchedules, at: 0)
            
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: state.currentDisplayDate) {
                state.currentDisplayDate = previousDay
            }
            return []
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            return []
            
        case .setLoadingNextDay(let isLoading):
            state.isLoadingNextDay = isLoading
            return []
            
        case .setCurrentDisplayDate(let date):
            let calendar = Calendar.current
            let newDate = calendar.startOfDay(for: date)
            let currentDate = calendar.startOfDay(for: state.currentDisplayDate)
            
            if !calendar.isDate(newDate, inSameDayAs: currentDate) {
                state.currentDisplayDate = newDate
                state.homeTitle = newDate.toString()
            }
            return []
            
        // MARK: - Date Picker
        case let .setTempSelectedDate(date):
            state.tempSelectedDate = date
            return []
            
        case .confirmSelectedDate:
            let calendar = Calendar.current
            let newDate = calendar.startOfDay(for: state.tempSelectedDate)
            let currentDate = calendar.startOfDay(for: state.currentDisplayDate)
            if !calendar.isDate(newDate, inSameDayAs: currentDate) {
                state.currentDisplayDate = newDate
                state.homeTitle = newDate.toString()
            }
            return []
        case let .showCalendarView(isPresented):
            state.showCalendarSheet = isPresented
            return []
        case let .showAlarmSheet(isPresented):
            state.showAlarmSheet = isPresented
            return []
        case let .showScheduleSheet(isPresented):
            state.showScheduleSheet = isPresented
            return []
        }
    }
    
    // MARK: - Helpers
    private func formatWakeDurationDescription(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours > 0 {
            return String(
                format: "HomeWakeDurationFormatHours".localized(),
                locale: currentLocale,
                hours, minutes
            )
        } else if minutes > 0 {
            return String(
                format: "HomeWakeDurationFormatMinutes".localized(),
                locale: currentLocale,
                minutes, seconds
            )
        } else {
            return String(
                format: "HomeWakeDurationFormatSeconds".localized(),
                locale: currentLocale,
                seconds
            )
        }
    }
    
    private func normalizedDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    private func reminderSortPredicate(_ lhs: MemosEntity, _ rhs: MemosEntity) -> Bool {
        let leftDate = lhs.createdAt ?? Date.distantPast
        let rightDate = rhs.createdAt ?? Date.distantPast
        if leftDate != rightDate {
            return leftDate < rightDate
        }
        return (lhs.reminderTime ?? "") < (rhs.reminderTime ?? "")
    }
    
    private var currentLocale: Locale {
        Locale(identifier: LocalizationController.shared.languageCode)
    }
    
    private func formatDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
