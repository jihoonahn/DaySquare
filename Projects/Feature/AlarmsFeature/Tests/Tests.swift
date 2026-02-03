import Foundation
import Testing
import Rex
@testable import AlarmsFeature
import AlarmsFeatureInterface
import AlarmsDomainInterface
import UsersDomainInterface
import AlarmsFeatureTesting

struct AlarmsFeatureTests {

    @Test("loadAlarms 시 isLoading true, errorMessage nil")
    func loadAlarmsSetsLoading() async throws {
        let mockAlarms = MockAlarmsUseCaseForFeature()
        mockAlarms.fetchAllResult = []
        let mockSchedules = MockAlarmSchedulesUseCaseForFeature()
        let mockUsers = MockUsersUseCaseForAlarms()
        mockUsers.getCurrentUserResult = UsersEntity(
            id: UUID(),
            provider: "test",
            email: "t@t.com",
            displayName: "T",
            createdAt: Date(),
            updatedAt: Date()
        )
        let reducer = AlarmReducer(
            alarmsUseCase: mockAlarms,
            alarmSchedulesUseCase: mockSchedules,
            usersUseCase: mockUsers,
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        var state = AlarmState()
        _ = reducer.reduce(state: &state, action: .loadAlarms)
        #expect(state.isLoading == true)
        #expect(state.errorMessage == nil)
    }

    @Test("setAlarms 시 alarms 정렬 저장, isLoading false")
    func setAlarmsUpdatesState() async throws {
        let reducer = AlarmReducer(
            alarmsUseCase: MockAlarmsUseCaseForFeature(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForAlarms(),
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        let id1 = UUID()
        let id2 = UUID()
        let alarms: [AlarmsEntity] = [
            AlarmsEntity(id: id1, userId: UUID(), label: nil, time: "10:00", repeatDays: [], snoozeEnabled: false, snoozeInterval: 5, snoozeLimit: 3, soundName: "default", soundURL: nil, vibrationPattern: nil, volumeOverride: nil, isEnabled: true, createdAt: Date(), updatedAt: Date()),
            AlarmsEntity(id: id2, userId: UUID(), label: nil, time: "08:00", repeatDays: [], snoozeEnabled: false, snoozeInterval: 5, snoozeLimit: 3, soundName: "default", soundURL: nil, vibrationPattern: nil, volumeOverride: nil, isEnabled: true, createdAt: Date(), updatedAt: Date())
        ]
        var state = AlarmState()
        state.isLoading = true
        _ = reducer.reduce(state: &state, action: .setAlarms(alarms))
        #expect(state.isLoading == false)
        #expect(state.alarms.count == 2)
        #expect(state.alarms[0].time == "08:00")
        #expect(state.alarms[1].time == "10:00")
    }

    @Test("showingAddAlarmState(true) 시 showingAddAlarm true")
    func showingAddAlarmUpdatesState() async throws {
        let reducer = AlarmReducer(
            alarmsUseCase: MockAlarmsUseCaseForFeature(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForAlarms(),
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        var state = AlarmState()
        _ = reducer.reduce(state: &state, action: .showingAddAlarmState(true))
        #expect(state.showingAddAlarm == true)
        _ = reducer.reduce(state: &state, action: .showingAddAlarmState(false))
        #expect(state.showingAddAlarm == false)
    }

    @Test("setError 시 errorMessage 설정")
    func setErrorUpdatesMessage() async throws {
        let reducer = AlarmReducer(
            alarmsUseCase: MockAlarmsUseCaseForFeature(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForAlarms(),
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        var state = AlarmState()
        _ = reducer.reduce(state: &state, action: .setError("error"))
        #expect(state.errorMessage == "error")
        _ = reducer.reduce(state: &state, action: .setError(nil))
        #expect(state.errorMessage == nil)
    }

    @Test("labelTextFieldDidChange 시 label 업데이트")
    func labelTextFieldUpdatesLabel() async throws {
        let reducer = AlarmReducer(
            alarmsUseCase: MockAlarmsUseCaseForFeature(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForAlarms(),
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        var state = AlarmState()
        _ = reducer.reduce(state: &state, action: .labelTextFieldDidChange("기상"))
        #expect(state.label == "기상")
    }

    @Test("toggleRepeatDay 시 selectedDays 토글")
    func toggleRepeatDayUpdatesSelectedDays() async throws {
        let reducer = AlarmReducer(
            alarmsUseCase: MockAlarmsUseCaseForFeature(),
            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForAlarms(),
            memosUseCase: MockMemosUseCaseForAlarms()
        )
        var state = AlarmState()
        _ = reducer.reduce(state: &state, action: .toggleRepeatDay(0))
        #expect(state.selectedDays.contains(0))
        _ = reducer.reduce(state: &state, action: .toggleRepeatDay(0))
        #expect(!state.selectedDays.contains(0))
    }
}
