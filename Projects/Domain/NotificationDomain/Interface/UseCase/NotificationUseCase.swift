import Foundation

public protocol NotificationUseCase: Sendable {
    func loadPreference(userId: UUID) async throws -> NotificationEntity?
    func updatePreference(userId: UUID, isEnabled: Bool) async throws
    func updatePermissions(enabled: Bool) async
}
