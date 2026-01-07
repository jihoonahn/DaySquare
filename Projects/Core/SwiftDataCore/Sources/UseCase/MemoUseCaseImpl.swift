import Foundation
import MemosDomainInterface

public final class MemoUseCaseImpl: MemosUseCase {
    
    private let memoRepository: MemosRepository
    
    public init(memoRepository: MemosRepository) {
        self.memoRepository = memoRepository
    }
    
    public func createMemo(_ memo: MemosEntity) async throws {
        return try await memoRepository.createMemo(memo)
    }
    
    public func updateMemo(_ memo: MemosEntity) async throws {
        return try await memoRepository.updateMemo(memo)
    }
    
    public func deleteMemo(id: UUID) async throws {
        try await memoRepository.deleteMemo(id: id)
    }
    
    public func getMemo(id: UUID) async throws -> MemosEntity {
        return try await memoRepository.fetchMemo(id: id)
    }
    
    public func getMemos(userId: UUID) async throws -> [MemosEntity] {
        return try await memoRepository.fetchMemos(userId: userId)
    }
    
    public func searchMemos(userId: UUID, keyword: String) async throws -> [MemosEntity] {
        return try await memoRepository.searchMemos(userId: userId, keyword: keyword)
    }
    
    public func getMemosByAlarmId(alarmId: UUID) async throws -> [MemosEntity] {
        return try await memoRepository.fetchMemosByAlarmId(alarmId: alarmId)
    }
    
    public func getMemosByScheduleId(scheduleId: UUID) async throws -> [MemosEntity] {
        return try await memoRepository.fetchMemosByScheduleId(scheduleId: scheduleId)
    }
}
