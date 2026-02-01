import Foundation
import Testing
@testable import SwiftDataCore
@testable import SwiftDataCoreTesting
import AlarmsDomainInterface

struct SwiftDataCoreTests {

    @Test("AlarmUseCaseImpl fetchAll 호출 시 repository에 전달")
    func useCaseFetchAllDelegatesToRepository() async throws {
        let mock = MockAlarmsRepositoryForSwiftData()
        mock.fetchAlarmsResult = [SwiftDataCoreTesting.makeAlarm()]
        let useCase = AlarmUseCaseImpl(alarmRepository: mock)
        let result = try await useCase.fetchAll(userId: UUID())
        #expect(result.count == 1)
        #expect(result[0].time == "09:00")
    }

    @Test("AlarmUseCaseImpl create 호출 시 repository에 전달")
    func useCaseCreateDelegatesToRepository() async throws {
        let mock = MockAlarmsRepositoryForSwiftData()
        let useCase = AlarmUseCaseImpl(alarmRepository: mock)
        try await useCase.create(SwiftDataCoreTesting.makeAlarm())
        #expect(mock.createAlarmCalled == true)
    }

    @Test("AlarmUseCaseImpl delete 호출 시 repository에 전달")
    func useCaseDeleteDelegatesToRepository() async throws {
        let mock = MockAlarmsRepositoryForSwiftData()
        let useCase = AlarmUseCaseImpl(alarmRepository: mock)
        try await useCase.delete(id: UUID())
        #expect(mock.deleteAlarmCalled == true)
    }

    @Test("AlarmUseCaseImpl toggle 호출 시 repository에 전달")
    func useCaseToggleDelegatesToRepository() async throws {
        let mock = MockAlarmsRepositoryForSwiftData()
        let useCase = AlarmUseCaseImpl(alarmRepository: mock)
        try await useCase.toggle(id: UUID(), isEnabled: false)
        #expect(mock.toggleAlarmCalled == true)
    }
}
