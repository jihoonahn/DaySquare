import Foundation
import AlarmsDomainInterface
import SupabaseCore
import SwiftDataCore

/// Supabase(클라우드) 우선, 오프라인 시 SwiftData(로컬) 폴백
public final class AlarmsSyncRepository: AlarmsRepository, @unchecked Sendable {

    private let remote: AlarmsRepository
    private let local: AlarmsRepository

    public init(remote: AlarmsRepository, local: AlarmsRepository) {
        self.remote = remote
        self.local = local
    }

    public func fetchAlarms(userId: UUID) async throws -> [AlarmsEntity] {
        do {
            return try await remote.fetchAlarms(userId: userId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchAlarms(userId: userId)
        }
    }

    public func createAlarm(_ alarm: AlarmsEntity) async throws {
        do {
            try await remote.createAlarm(alarm)
            try? await local.createAlarm(alarm)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.createAlarm(alarm)
        }
    }

    public func updateAlarm(_ alarm: AlarmsEntity) async throws {
        do {
            try await remote.updateAlarm(alarm)
            try? await local.updateAlarm(alarm)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.updateAlarm(alarm)
        }
    }

    public func deleteAlarm(alarmId: UUID) async throws {
        do {
            try await remote.deleteAlarm(alarmId: alarmId)
            try? await local.deleteAlarm(alarmId: alarmId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.deleteAlarm(alarmId: alarmId)
        }
    }

    public func toggleAlarm(alarmId: UUID, isEnabled: Bool) async throws {
        do {
            try await remote.toggleAlarm(alarmId: alarmId, isEnabled: isEnabled)
            try? await local.toggleAlarm(alarmId: alarmId, isEnabled: isEnabled)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.toggleAlarm(alarmId: alarmId, isEnabled: isEnabled)
        }
    }

}
