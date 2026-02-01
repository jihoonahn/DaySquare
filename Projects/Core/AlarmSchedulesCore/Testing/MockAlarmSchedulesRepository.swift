import Foundation
import AlarmSchedulesCoreInterface
import AlarmsDomainInterface

// MARK: - Mock AlarmSchedulesRepository
public final class MockAlarmSchedulesRepository: AlarmSchedulesRepository, @unchecked Sendable {
    public var scheduleAlarmCalled = false
    public var cancelAlarmCalled = false
    public var updateAlarmCalled = false
    public var toggleAlarmCalled = false
    public var stopAlarmCalled = false
    public var scheduleAlarmError: Error?
    public var lastScheduledAlarm: AlarmsEntity?

    public init() {}

    public func scheduleAlarm(_ alarm: AlarmsEntity) async throws {
        scheduleAlarmCalled = true
        lastScheduledAlarm = alarm
        if let error = scheduleAlarmError { throw error }
    }

    public func cancelAlarm(_ alarmId: UUID) async throws {
        cancelAlarmCalled = true
    }

    public func updateAlarm(_ alarm: AlarmsEntity) async throws {
        updateAlarmCalled = true
    }

    public func toggleAlarm(_ alarmId: UUID, isEnabled: Bool) async throws {
        toggleAlarmCalled = true
    }

    public func stopAlarm(_ alarmId: UUID) async throws {
        stopAlarmCalled = true
    }
}

// MARK: - Test Fixtures
public enum AlarmSchedulesCoreTesting {
    public static func makeAlarm(id: UUID = UUID(), time: String = "09:00") -> AlarmsEntity {
        let now = Date()
        return AlarmsEntity(
            id: id,
            userId: UUID(),
            label: "Test",
            time: time,
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
