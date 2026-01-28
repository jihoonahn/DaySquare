import Foundation
import AlarmKit
import Rex
import AlarmsFeatureInterface
import AlarmsDomainInterface
import AlarmSchedulesCoreInterface
import UsersDomainInterface
import MemosDomainInterface
import Dependency
import Localization
import Utility
import BaseFeature

public struct AlarmReducer: Reducer {
    private let alarmsUseCase: AlarmsUseCase
    private let alarmSchedulesUseCase: AlarmSchedulesUseCase
    private let usersUseCase: UsersUseCase
    private let memosUseCase: MemosUseCase
    
    public init(
        alarmsUseCase: AlarmsUseCase,
        alarmSchedulesUseCase: AlarmSchedulesUseCase,
        usersUseCase: UsersUseCase,
        memosUseCase: MemosUseCase
    ) {
        self.alarmsUseCase = alarmsUseCase
        self.alarmSchedulesUseCase = alarmSchedulesUseCase
        self.usersUseCase = usersUseCase
        self.memosUseCase = memosUseCase
    }
    // MARK: - Reduce
    
    public func reduce(state: inout AlarmState, action: AlarmAction) -> [Effect<AlarmAction>] {
        switch action {
        case .loadAlarms:
            state.isLoading = true
            state.errorMessage = nil
            return [
                Effect { [self] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            throw AlarmError.userNotFound
                        }
                        let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                        emitter.send(.setAlarms(alarms))
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorLoadFailed")
                        emitter.send(.setError(errorMessage))
                    }
                }
            ]
            
        case .setAlarms(let alarms):
            state.isLoading = false
            state.alarms = alarms.sorted { $0.time < $1.time }
            return []
            
        case .createAlarm(let time, let label, let repeatDays):
            state.errorMessage = nil
            return [
                Effect { [self] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            throw AlarmError.userNotFound
                        }
                        let newAlarm = AlarmsEntity(
                            id: UUID(),
                            userId: user.id,
                            label: label?.isEmpty == false ? label : nil,
                            time: time,
                            repeatDays: repeatDays,
                            snoozeEnabled: true,
                            snoozeInterval: 5,
                            snoozeLimit: 3,
                            soundName: "default",
                            soundURL: nil,
                            vibrationPattern: nil,
                            volumeOverride: nil,
                            isEnabled: true,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                        emitter.send(.addAlarm(newAlarm))
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorCreateFailed")
                        emitter.send(.setError(errorMessage))
                    }
                }
            ]
            
        case .addAlarm(let alarm):
            if state.alarms.contains(where: { $0.id == alarm.id }) {
                return []
            }
            
            state.alarms.append(alarm)
            state.alarms.sort { $0.time < $1.time }
            state.errorMessage = nil
            
            let shouldAddMemo = state.addMemoWithAlarm
            let memoContent = state.memoContent
            
            return [
                Effect { [self, alarm, shouldAddMemo, memoContent] emitter in
                    do {
                        try await alarmsUseCase.create(alarm)
                        
                        if alarm.isEnabled {
                            try await alarmSchedulesUseCase.scheduleAlarm(alarm)
                        }
                        
                        // 메모 생성
                        if shouldAddMemo && !memoContent.isEmpty {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            
                            let memo = MemosEntity(
                                id: UUID(),
                                userId: user.id,
                                title: alarm.label ?? "AlarmMemoTitle".localized(),
                                description: memoContent,
                                blocks: [
                                    MemoBlockEntity(
                                        type: .text,
                                        content: memoContent
                                    )
                                ],
                                alarmId: alarm.id,
                                scheduleId: nil,
                                reminderTime: alarm.time,
                                createdAt: Date(),
                                updatedAt: Date()
                            )
                            
                            try await memosUseCase.createMemo(memo)
                        }
                        
                        // EventBus로 데이터 변경 알림
                        await GlobalEventBus.shared.publish(AlarmDataEvent.created)
                        
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                        emitter.send(.showingAddAlarmState(false))
                        
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorAddFailed")
                        emitter.send(.setError(errorMessage))
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                    }
                }
            ]
            
        case .updateAlarm(let alarm):
            if let index = state.alarms.firstIndex(where: { $0.id == alarm.id }) {
                state.alarms[index] = alarm
                state.alarms.sort { $0.time < $1.time }
            }
            state.errorMessage = nil
            
            let shouldAddMemo = state.addMemoWithAlarm
            let memoContent = state.memoContent
            
            return [
                Effect { [self, alarm, shouldAddMemo, memoContent] emitter in
                    do {
                        try await alarmsUseCase.update(alarm)
                        try await alarmSchedulesUseCase.updateAlarm(alarm)
                        
                        // 메모 처리
                        if shouldAddMemo && !memoContent.isEmpty {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            
                            // 기존 메모가 있는지 확인
                            let existingMemos = try await memosUseCase.getMemosByAlarmId(alarmId: alarm.id)
                            
                            if let existingMemo = existingMemos.first {
                                // 기존 메모 업데이트
                                let updatedMemo = MemosEntity(
                                    id: existingMemo.id,
                                    userId: existingMemo.userId,
                                    title: alarm.label ?? "AlarmMemoTitle".localized(),
                                    description: memoContent,
                                    blocks: [
                                        MemoBlockEntity(
                                            type: .text,
                                            content: memoContent
                                        )
                                    ],
                                    alarmId: alarm.id,
                                    scheduleId: nil,
                                    reminderTime: alarm.time,
                                    createdAt: existingMemo.createdAt,
                                    updatedAt: Date()
                                )
                                try await memosUseCase.updateMemo(updatedMemo)
                            } else {
                                // 새 메모 생성
                                let memo = MemosEntity(
                                    id: UUID(),
                                    userId: user.id,
                                    title: alarm.label ?? "AlarmMemoTitle".localized(),
                                    description: memoContent,
                                    blocks: [
                                        MemoBlockEntity(
                                            type: .text,
                                            content: memoContent
                                        )
                                    ],
                                    alarmId: alarm.id,
                                    scheduleId: nil,
                                    reminderTime: alarm.time,
                                    createdAt: Date(),
                                    updatedAt: Date()
                                )
                                try await memosUseCase.createMemo(memo)
                            }
                        } else if shouldAddMemo && memoContent.isEmpty {
                            // 메모 활성화되었지만 내용이 비어있으면 기존 메모 삭제
                            let existingMemos = try await memosUseCase.getMemosByAlarmId(alarmId: alarm.id)
                            for memo in existingMemos {
                                try await memosUseCase.deleteMemo(id: memo.id)
                            }
                        }
                        
                        // EventBus로 데이터 변경 알림
                        await GlobalEventBus.shared.publish(AlarmDataEvent.updated)
                        
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                        emitter.send(.showingEditAlarmState(nil))                        
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorUpdateFailed")
                        emitter.send(.setError(errorMessage))
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                    }
                }
            ]
            
        case .deleteAlarm(let id):
            state.alarms.removeAll { $0.id == id }
            state.errorMessage = nil
            
            return [
                Effect { [self, id] emitter in
                    do {
                        try await alarmsUseCase.delete(id: id)
                        
                        do {
                            try await alarmSchedulesUseCase.cancelAlarm(id)
                        } catch {
                            // 알람 스케줄링 취소 실패 (무시됨)
                        }
                        
                        // EventBus로 데이터 변경 알림
                        await GlobalEventBus.shared.publish(AlarmDataEvent.deleted)
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorDeleteFailed")
                        emitter.send(.setError(errorMessage))
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                    }
                }
            ]
            
        case .toggleAlarm(let id):
            guard let alarmIndex = state.alarms.firstIndex(where: { $0.id == id }) else {
                return []
            }
            
            let newIsEnabled = !state.alarms[alarmIndex].isEnabled
            state.alarms[alarmIndex].isEnabled = newIsEnabled
            state.errorMessage = nil
            
            return [
                Effect { [self, id, newIsEnabled] emitter in
                    do {
                        try await alarmsUseCase.toggle(id: id, isEnabled: newIsEnabled)
                        
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            throw AlarmError.userNotFound
                        }
                        let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                        guard let alarm = alarms.first(where: { $0.id == id }) else {
                            throw AlarmServiceError.entityNotFound
                        }
                        
                        if newIsEnabled {
                            try await alarmSchedulesUseCase.scheduleAlarm(alarm)
                        } else {
                            try await alarmSchedulesUseCase.cancelAlarm(id)
                        }
                        
                        // EventBus로 데이터 변경 알림
                        await GlobalEventBus.shared.publish(AlarmDataEvent.toggled)
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorToggleFailed")
                        emitter.send(.setError(errorMessage))
                        do {
                            guard let user = try await usersUseCase.getCurrentUser() else {
                                throw AlarmError.userNotFound
                            }
                            let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                            emitter.send(.setAlarms(alarms))
                        } catch {
                            // 알람 목록 재로드 실패
                        }
                    }
                }
            ]
            
        case .updateAlarmWithData(let id, let time, let label, let repeatDays):
            state.errorMessage = nil

            return [
                Effect { [self, id, time, label, repeatDays] emitter in
                    do {
                        guard let user = try await usersUseCase.getCurrentUser() else {
                            throw AlarmError.userNotFound
                        }
                        let alarms = try await alarmsUseCase.fetchAll(userId: user.id)
                        guard let existingAlarm = alarms.first(where: { $0.id == id }) else {
                            emitter.send(.setError("AlarmErrorEntityNotFound".localized()))
                            return
                        }
                        
                        let updatedAlarm = AlarmsEntity(
                            id: existingAlarm.id,
                            userId: existingAlarm.userId,
                            label: label?.isEmpty == false ? label : nil,
                            time: time,
                            repeatDays: repeatDays,
                            snoozeEnabled: existingAlarm.snoozeEnabled,
                            snoozeInterval: existingAlarm.snoozeInterval,
                            snoozeLimit: existingAlarm.snoozeLimit,
                            soundName: existingAlarm.soundName,
                            soundURL: existingAlarm.soundURL,
                            vibrationPattern: existingAlarm.vibrationPattern,
                            volumeOverride: existingAlarm.volumeOverride,
                            isEnabled: existingAlarm.isEnabled,
                            createdAt: existingAlarm.createdAt,
                            updatedAt: Date()
                        )
                        emitter.send(.updateAlarm(updatedAlarm))
                    } catch {
                        let errorMessage = AlarmError.formatErrorMessage(error, key: "AlarmErrorUpdateFailed")
                        emitter.send(.setError(errorMessage))
                    }
                }
            ]
            
        case .setError(let message):
            state.isLoading = false
            state.errorMessage = message
            return []
            
        case let .showingAddAlarmState(status):
            state.showingAddAlarm = status
            state.date = Date()
            state.label = ""
            state.selectedDays = []
            state.isRepeating = false
            state.addMemoWithAlarm = false
            state.memoContent = ""
            return []
            
        case let .showingEditAlarmState(alarm):
            state.editingAlarm = alarm
            return []
            
        case .stopAlarm(let id):
            return [
                Effect { [self, id] emitter in
                    do {
                        try await alarmSchedulesUseCase.stopAlarm(id)
                    } catch {
                        // 알람 중지 실패
                    }
                }
            ]
            
        case let .labelTextFieldDidChange(text):
            state.label = text
            return []
            
        case let .datePickerDidChange(date):
            state.date = date
            return []
            
        case let .toggleRepeatDay(day):
            if state.selectedDays.contains(day) {
                state.selectedDays.remove(day)
            } else {
                state.selectedDays.insert(day)
            }
            state.isRepeating = !state.selectedDays.isEmpty
            return []
            
        case let .setRepeatDays(days):
            state.selectedDays = days
            state.isRepeating = !days.isEmpty
            return []
            
        case let .setIsRepeating(isRepeating):
            state.isRepeating = isRepeating
            return []
            
        case let .initializeEditAlarmState(alarm):
            let components = alarm.time.split(separator: ":")
            let hour = components.count >= 1 ? Int(components[0]) ?? 0 : 0
            let minute = components.count >= 2 ? Int(components[1]) ?? 0 : 0
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            state.selectedTime = Calendar.current.date(from: dateComponents) ?? Date()
            state.date = state.selectedTime
            state.label = alarm.label ?? ""
            state.selectedDays = Set(alarm.repeatDays)
            state.isRepeating = !alarm.repeatDays.isEmpty
            
            // 기존 메모 로드
            return [
                Effect { [self] emitter in
                    do {
                        let memos = try await memosUseCase.getMemosByAlarmId(alarmId: alarm.id)
                        if let memo = memos.first {
                            emitter.send(.setMemoContent(memo.description, hasContent: true))
                        } else {
                            emitter.send(.setMemoContent("", hasContent: false))
                        }
                    } catch {
                        emitter.send(.setMemoContent("", hasContent: false))
                    }
                }
            ]
            
        case .toggleAddMemoWithAlarm(let enabled):
            state.addMemoWithAlarm = enabled
            if !enabled {
                state.memoContent = ""
            }
            return []
            
        case .memoContentTextFieldDidChange(let text):
            state.memoContent = text
            return []
            
        case .setMemoContent(let content, let hasContent):
            state.memoContent = content
            state.addMemoWithAlarm = hasContent
            return []
            
        case .saveAddAlarm:
            let timeString = String().formatTimeString(from: state.date)
            let alarmLabel = state.label.isEmpty ? nil : state.label
            let repeatDays = state.isRepeating ? Array(state.selectedDays).sorted() : []
            
            return [
                Effect { [timeString, alarmLabel, repeatDays] emitter in
                    emitter.send(.createAlarm(time: timeString, label: alarmLabel, repeatDays: repeatDays))
                }
            ]
            
        case .saveEditAlarm:
            guard let editingAlarm = state.editingAlarm else {
                return []
            }
            
            let timeString = String().formatTimeString(from: state.date)
            let alarmLabel = state.label.isEmpty ? nil : state.label
            let repeatDays = state.isRepeating ? Array(state.selectedDays).sorted() : []
            
            return [
                Effect { [editingAlarm, timeString, alarmLabel, repeatDays] emitter in
                    emitter.send(.updateAlarmWithData(
                        id: editingAlarm.id,
                        time: timeString,
                        label: alarmLabel,
                        repeatDays: repeatDays
                    ))
                }
            ]
        }
    }
}

// MARK: - AlarmError

enum AlarmError: Error {
    case userNotFound
    
    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "AlarmErrorUserNotFound".localized()
        }
    }
    
    static func formatErrorMessage(_ error: Error, key: String) -> String {
        if let alarmError = error as? AlarmError {
            return String(format: key.localized(), alarmError.localizedDescription)
        } else {
            return String(format: key.localized(), error.localizedDescription)
        }
    }
}
