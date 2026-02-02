import Foundation
import NotificationDomainInterface

// MARK: - Mock NotificationUseCase
public final class MockNotificationUseCaseForSettings: NotificationUseCase, @unchecked Sendable {
    public init() {}

    public func loadPreference(userId: UUID) async throws -> NotificationEntity? {
        NotificationEntity(isEnabled: true)
    }

    public func updatePreference(userId: UUID, isEnabled: Bool) async throws {}

    public func updatePermissions(enabled: Bool) async {}
}
