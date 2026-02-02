import Foundation
import SchedulesDomainInterface
import SupabaseCore
import SwiftDataCore

/// Supabase(클라우드) 우선, 오프라인 시 SwiftData(로컬) 폴백
public final class SchedulesSyncRepository: SchedulesRepository, @unchecked Sendable {

    private let remote: SchedulesRepository
    private let local: SchedulesRepository

    public init(remote: SchedulesRepository, local: SchedulesRepository) {
        self.remote = remote
        self.local = local
    }

    public func fetchSchedules(userId: UUID) async throws -> [SchedulesEntity] {
        do {
            return try await remote.fetchSchedules(userId: userId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchSchedules(userId: userId)
        }
    }

    public func fetchSchedule(id: UUID) async throws -> SchedulesEntity {
        do {
            return try await remote.fetchSchedule(id: id)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchSchedule(id: id)
        }
    }

    public func createSchedule(_ schedule: SchedulesEntity) async throws {
        do {
            try await remote.createSchedule(schedule)
            try? await local.createSchedule(schedule)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.createSchedule(schedule)
        }
    }

    public func updateSchedule(_ schedule: SchedulesEntity) async throws {
        do {
            try await remote.updateSchedule(schedule)
            try? await local.updateSchedule(schedule)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.updateSchedule(schedule)
        }
    }

    public func deleteSchedule(id: UUID) async throws {
        do {
            try await remote.deleteSchedule(id: id)
            try? await local.deleteSchedule(id: id)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.deleteSchedule(id: id)
        }
    }
}
