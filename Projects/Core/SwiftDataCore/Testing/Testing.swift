import Foundation
import SwiftDataCoreInterface
import AlarmsDomainInterface

// MARK: - Mock AlarmsRepository (SwiftDataCore UseCase 테스트용)
public final class MockAlarmsRepositoryForSwiftData: AlarmsRepository, @unchecked Sendable {
    public var fetchAlarmsResult: [AlarmsEntity] = []
    public var fetchAlarmsError: Error?
    public var createAlarmCalled = false
    public var updateAlarmCalled = false
    public var deleteAlarmCalled = false
    public var toggleAlarmCalled = false

    public init() {}

    public func fetchAlarms(userId: UUID) async throws -> [AlarmsEntity] {
        if let error = fetchAlarmsError { throw error }
        return fetchAlarmsResult
    }

    public func createAlarm(_ alarm: AlarmsEntity) async throws {
        createAlarmCalled = true
    }

    public func updateAlarm(_ alarm: AlarmsEntity) async throws {
        updateAlarmCalled = true
    }

    public func deleteAlarm(alarmId: UUID) async throws {
        deleteAlarmCalled = true
    }

    public func toggleAlarm(alarmId: UUID, isEnabled: Bool) async throws {
        toggleAlarmCalled = true
    }
}

// MARK: - Test Fixtures
public enum SwiftDataCoreTesting {
    public static func makeAlarm() -> AlarmsEntity {
        let now = Date()
        return AlarmsEntity(
            id: UUID(),
            userId: UUID(),
            label: "Test",
            time: "09:00",
            repeatDays: [1, 2, 3, 4, 5],
            snoozeEnabled: true,
            snoozeInterval: 5,
            snoozeLimit: 3,
            soundName: "default",
            soundURL: nil,
            vibrationPattern: nil,
            volumeOverride: nil,
            isEnabled: true,
            createdAt: now,
            updatedAt: now
        )
    }
}
