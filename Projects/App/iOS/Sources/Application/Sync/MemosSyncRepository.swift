import Foundation
import MemosDomainInterface
import SupabaseCore
import SwiftDataCore

/// Supabase(클라우드) 우선, 오프라인 시 SwiftData(로컬) 폴백
public final class MemosSyncRepository: MemosRepository, @unchecked Sendable {

    private let remote: MemosRepository
    private let local: MemosRepository

    public init(remote: MemosRepository, local: MemosRepository) {
        self.remote = remote
        self.local = local
    }

    public func createMemo(_ memo: MemosEntity) async throws {
        do {
            try await remote.createMemo(memo)
            try? await local.createMemo(memo)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.createMemo(memo)
        }
    }

    public func updateMemo(_ memo: MemosEntity) async throws {
        do {
            try await remote.updateMemo(memo)
            try? await local.updateMemo(memo)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.updateMemo(memo)
        }
    }

    public func deleteMemo(id: UUID) async throws {
        do {
            try await remote.deleteMemo(id: id)
            try? await local.deleteMemo(id: id)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            try await local.deleteMemo(id: id)
        }
    }

    public func fetchMemo(id: UUID) async throws -> MemosEntity {
        do {
            return try await remote.fetchMemo(id: id)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchMemo(id: id)
        }
    }

    public func fetchMemos(userId: UUID) async throws -> [MemosEntity] {
        do {
            return try await remote.fetchMemos(userId: userId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchMemos(userId: userId)
        }
    }

    public func searchMemos(userId: UUID, keyword: String) async throws -> [MemosEntity] {
        do {
            return try await remote.searchMemos(userId: userId, keyword: keyword)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.searchMemos(userId: userId, keyword: keyword)
        }
    }

    public func fetchMemosByAlarmId(alarmId: UUID) async throws -> [MemosEntity] {
        do {
            return try await remote.fetchMemosByAlarmId(alarmId: alarmId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchMemosByAlarmId(alarmId: alarmId)
        }
    }

    public func fetchMemosByScheduleId(scheduleId: UUID) async throws -> [MemosEntity] {
        do {
            return try await remote.fetchMemosByScheduleId(scheduleId: scheduleId)
        } catch where NetworkErrorChecker.isNetworkError(error) {
            return try await local.fetchMemosByScheduleId(scheduleId: scheduleId)
        }
    }
}
