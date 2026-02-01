import Foundation
import Testing
import AlarmsDomainInterface
@testable import AlarmSchedulesCore
@testable import AlarmSchedulesCoreTesting

struct AlarmSchedulesCoreTests {

    @Test("AlarmScheduleUseCaseImpl scheduleAlarm 호출 시 repository에 전달")
    func useCaseScheduleAlarmDelegatesToRepository() async throws {
        let mockRepo = MockAlarmSchedulesRepository()
        let useCase = AlarmScheduleUseCaseImpl(repository: mockRepo)
        let alarm = AlarmSchedulesCoreTesting.makeAlarm()
        try await useCase.scheduleAlarm(alarm)
        #expect(mockRepo.scheduleAlarmCalled == true)
        #expect(mockRepo.lastScheduledAlarm?.id == alarm.id)
        #expect(mockRepo.lastScheduledAlarm?.time == "09:00")
    }

    @Test("AlarmScheduleUseCaseImpl cancelAlarm 호출 시 repository에 전달")
    func useCaseCancelAlarmDelegatesToRepository() async throws {
        let mockRepo = MockAlarmSchedulesRepository()
        let useCase = AlarmScheduleUseCaseImpl(repository: mockRepo)
        let alarmId = UUID()
        try await useCase.cancelAlarm(alarmId)
        #expect(mockRepo.cancelAlarmCalled == true)
    }

    @Test("AlarmScheduleUseCaseImpl toggleAlarm 호출 시 repository에 전달")
    func useCaseToggleAlarmDelegatesToRepository() async throws {
        let mockRepo = MockAlarmSchedulesRepository()
        let useCase = AlarmScheduleUseCaseImpl(repository: mockRepo)
        try await useCase.toggleAlarm(UUID(), isEnabled: false)
        #expect(mockRepo.toggleAlarmCalled == true)
    }

    @Test("AlarmScheduleUseCaseImpl updateAlarm 호출 시 repository에 전달")
    func useCaseUpdateAlarmDelegatesToRepository() async throws {
        let mockRepo = MockAlarmSchedulesRepository()
        let useCase = AlarmScheduleUseCaseImpl(repository: mockRepo)
        let alarm = AlarmSchedulesCoreTesting.makeAlarm(time: "10:30")
        try await useCase.updateAlarm(alarm)
        #expect(mockRepo.updateAlarmCalled == true)
    }

    @Test("AlarmScheduleUseCaseImpl stopAlarm 호출 시 repository에 전달")
    func useCaseStopAlarmDelegatesToRepository() async throws {
        let mockRepo = MockAlarmSchedulesRepository()
        let useCase = AlarmScheduleUseCaseImpl(repository: mockRepo)
        try await useCase.stopAlarm(UUID())
        #expect(mockRepo.stopAlarmCalled == true)
    }
}
