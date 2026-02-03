import Testing
import Rex
@testable import HomeFeature
import HomeFeatureInterface
import MemosDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import HomeFeatureTesting

struct HomeFeatureTests {

    @Test("loadHomeData 시 isLoading true")
    func loadHomeDataSetsLoading() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        _ = reducer.reduce(state: &state, action: .loadHomeData)
        #expect(state.isLoading == true)
    }

    @Test("setHomeData 시 alarms, schedules, allMemos 저장, isLoading false")
    func setHomeDataUpdatesState() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        state.isLoading = true
        let memos: [MemosEntity] = []
        let alarms: [AlarmsEntity] = []
        let schedules: [SchedulesEntity] = []
        _ = reducer.reduce(state: &state, action: .setHomeData(wakeDuration: nil, memos: memos, alarms: alarms, schedules: schedules))
        #expect(state.isLoading == false)
        #expect(state.allMemos.isEmpty)
        #expect(state.alarms.isEmpty)
        #expect(state.schedules.isEmpty)
    }

    @Test("setLoading(true/false) 시 isLoading 업데이트")
    func setLoading() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        _ = reducer.reduce(state: &state, action: .setLoading(true))
        #expect(state.isLoading == true)
        _ = reducer.reduce(state: &state, action: .setLoading(false))
        #expect(state.isLoading == false)
    }

    @Test("showCalendarView 시 showCalendarSheet 업데이트")
    func showCalendarView() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        _ = reducer.reduce(state: &state, action: .showCalendarView(true))
        #expect(state.showCalendarSheet == true)
        _ = reducer.reduce(state: &state, action: .showCalendarView(false))
        #expect(state.showCalendarSheet == false)
    }

    @Test("setCurrentDisplayDate 시 다른 날짜면 currentDisplayDate 업데이트")
    func setCurrentDisplayDate() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        _ = reducer.reduce(state: &state, action: .setCurrentDisplayDate(yesterday))
        #expect(calendar.isDate(state.currentDisplayDate, inSameDayAs: yesterday))
    }

    @Test("showAlarmSheet / showScheduleSheet 시 시트 상태 업데이트")
    func showSheets() throws {
        let reducer = HomeReducer(
            memosUseCase: MockMemosUseCaseForHome(),
            usersUseCase: MockUsersUseCaseForHome(),
            alarmsUseCase: MockAlarmsUseCaseForHome(),
            schedulesUseCase: MockSchedulesUseCaseForHome(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
            notificationService: MockNotificationServiceForHome()
        )
        var state = HomeState()
        _ = reducer.reduce(state: &state, action: .showAlarmSheet(true))
        #expect(state.showAlarmSheet == true)
        _ = reducer.reduce(state: &state, action: .showScheduleSheet(true))
        #expect(state.showScheduleSheet == true)
    }
}
