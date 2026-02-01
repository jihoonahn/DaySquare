import Foundation
import NotificationCoreInterface
import NotificationDomainInterface
import AlarmsDomainInterface

// MARK: - Mock NotificationRepository
public final class MockNotificationRepository: NotificationRepository, @unchecked Sendable {
    public var loadPreferenceResult: NotificationEntity?
    public var loadPreferenceError: Error?
    public var upsertPreferenceCalled = false
    public var updatePermissionsCalled = false
    public var scheduleFallbackNotificationsCalled = false
    public var clearFallbackNotificationsCalled = false
    public var clearScheduleNotificationsCalled = false

    public init() {}

    public func loadPreference(userId: UUID) async throws -> NotificationEntity? {
        if let error = loadPreferenceError { throw error }
        return loadPreferenceResult
    }

    public func upsertPreference(_ entity: NotificationEntity, for userId: UUID) async throws {
        upsertPreferenceCalled = true
    }

    public func updatePermissions(enabled: Bool) async {
        updatePermissionsCalled = true
    }

    public func scheduleFallbackNotifications(for alarms: [AlarmsEntity]) async {
        scheduleFallbackNotificationsCalled = true
    }

    public func clearFallbackNotifications() async {
        clearFallbackNotificationsCalled = true
    }

    public func clearScheduleNotifications() async {
        clearScheduleNotificationsCalled = true
    }
}

// MARK: - Test Fixtures
public enum NotificationCoreTesting {
    public static func makeNotificationEntity() -> NotificationEntity {
        NotificationEntity(isEnabled: true)
    }
}
