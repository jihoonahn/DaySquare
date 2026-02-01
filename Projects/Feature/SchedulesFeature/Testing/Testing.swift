import Foundation
import SchedulesFeatureInterface
import SchedulesDomainInterface
import UsersDomainInterface
import MemosDomainInterface

// MARK: - Mock SchedulesUseCase
public final class MockSchedulesUseCaseForFeature: SchedulesUseCase, @unchecked Sendable {
    public var getSchedulesResult: Result<[SchedulesEntity], Error> = .success([])
    public var getScheduleResult: Result<SchedulesEntity, Error>?
    public var createScheduleCalled = false
    public var updateScheduleCalled = false
    public var deleteScheduleCalled = false

    public init() {}

    public func getSchedules(userId: UUID) async throws -> [SchedulesEntity] {
        try getSchedulesResult.get()
    }

    public func getSchedule(id: UUID) async throws -> SchedulesEntity {
        guard let result = getScheduleResult else { fatalError("getScheduleResult not set") }
        return try result.get()
    }

    public func createSchedule(_ schedule: SchedulesEntity) async throws {
        createScheduleCalled = true
    }

    public func updateSchedule(_ schedule: SchedulesEntity) async throws {
        updateScheduleCalled = true
    }

    public func deleteSchedule(id: UUID) async throws {
        deleteScheduleCalled = true
    }
}

// MARK: - Mock UsersUseCase
public final class MockUsersUseCaseForFeature: UsersUseCase, @unchecked Sendable {
    public var getCurrentUserResult: UsersEntity?
    public var getCurrentUserError: Error?

    public init() {}

    public func login(provider: String, email: String?, displayName: String?) async throws {}
    public func updateUser(_ user: UsersEntity) async throws {}
    public func getCurrentUser() async throws -> UsersEntity? {
        if let error = getCurrentUserError { throw error }
        return getCurrentUserResult
    }
    public func deleteUser() async throws {}
    public func logout() async throws {}
}

// MARK: - Mock MemosUseCase
public final class MockMemosUseCaseForFeature: MemosUseCase, @unchecked Sendable {
    public init() {}
    public func createMemo(_ memo: MemosEntity) async throws {}
    public func updateMemo(_ memo: MemosEntity) async throws {}
    public func deleteMemo(id: UUID) async throws {}
    public func getMemo(id: UUID) async throws -> MemosEntity {
        fatalError("Not implemented")
    }
    public func getMemos(userId: UUID) async throws -> [MemosEntity] { [] }
    public func searchMemos(userId: UUID, keyword: String) async throws -> [MemosEntity] { [] }
    public func getMemosByAlarmId(alarmId: UUID) async throws -> [MemosEntity] { [] }
    public func getMemosByScheduleId(scheduleId: UUID) async throws -> [MemosEntity] { [] }
}

// MARK: - Test Fixtures
public enum SchedulesFeatureTesting {
    public static func makeSchedule(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        title: String = "Test",
        date: String = "2025-01-15",
        startTime: String = "09:00",
        endTime: String = "10:00"
    ) -> SchedulesEntity {
        let now = Date()
        return SchedulesEntity(
            id: id,
            userId: userId,
            title: title,
            description: "",
            date: date,
            startTime: startTime,
            endTime: endTime,
            createdAt: now,
            updatedAt: now
        )
    }

    public static func makeUser(id: UUID = UUID()) -> UsersEntity {
        let now = Date()
        return UsersEntity(
            id: id,
            provider: "apple",
            email: "test@test.com",
            displayName: "Test",
            createdAt: now,
            updatedAt: now
        )
    }
}
