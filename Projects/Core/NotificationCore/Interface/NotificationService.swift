import Foundation
import SchedulesDomainInterface

public protocol NotificationService: Sendable {
    func saveIsEnabled(_ isEnabled: Bool) async throws
    func loadIsEnabled() async throws -> Bool?
    func updatePermissions(enabled: Bool) async
    func scheduleNotifications(for schedules: [SchedulesEntity]) async
    func clearScheduleNotifications() async
}
