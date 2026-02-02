import Foundation
import AlarmsFeatureInterface
import AlarmsDomainInterface
import UsersDomainInterface
import MemosDomainInterface
import LocalizationDomainInterface

// MARK: - Mock AlarmsUseCase
public final class MockAlarmsUseCaseForFeature: AlarmsUseCase, @unchecked Sendable {
    public var fetchAllResult: [AlarmsEntity] = []
    public var fetchAllError: Error?

    public init() {}

    public func fetchAll(userId: UUID) async throws -> [AlarmsEntity] {
        if let error = fetchAllError { throw error }
        return fetchAllResult
    }
    public func create(_ alarm: AlarmsEntity) async throws {}
    public func update(_ alarm: AlarmsEntity) async throws {}
    public func delete(alarmId: UUID) async throws {}
    public func toggle(alarmId: UUID, isEnabled: Bool) async throws {}
}

// MARK: - Mock AlarmSchedulesUseCase
public final class MockAlarmSchedulesUseCaseForFeature: AlarmSchedulesUseCase, @unchecked Sendable {
    public init() {}
    public func scheduleAlarm(_ alarm: AlarmsEntity) async throws {}
    public func cancelAlarm(_ alarmId: UUID) async throws {}
    public func updateAlarm(_ alarm: AlarmsEntity) async throws {}
    public func toggleAlarm(_ alarmId: UUID, isEnabled: Bool) async throws {}
    public func stopAlarm(_ alarmId: UUID) async throws {}
}

// MARK: - Mock UsersUseCase
public final class MockUsersUseCaseForAlarms: UsersUseCase, @unchecked Sendable {
    public var getCurrentUserResult: UsersEntity?
    public var getCurrentUserError: Error?

    public init() {}

    public func login(provider: String, email: String?, displayName: String?) async throws {}
    public func updateUser(_ user: UsersEntity) async throws {}
    public func getCurrentUser() async throws -> UsersEntity? {
        if let error = getCurrentUserError { throw error }
        return getCurrentUserResult ?? UsersEntity(
            id: UUID(),
            provider: "example",
            email: "example@test.com",
            displayName: "Example",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    public func deleteUser() async throws {}
    public func logout() async throws {}
}

// MARK: - Mock MemosUseCase
public final class MockMemosUseCaseForAlarms: MemosUseCase, @unchecked Sendable {
    public init() {}
    public func createMemo(_ memo: MemosEntity) async throws {}
    public func updateMemo(_ memo: MemosEntity) async throws {}
    public func deleteMemo(id: UUID) async throws {}
    public func getMemo(id: UUID) async throws -> MemosEntity { fatalError("Not implemented") }
    public func getMemos(userId: UUID) async throws -> [MemosEntity] { [] }
    public func searchMemos(userId: UUID, keyword: String) async throws -> [MemosEntity] { [] }
    public func getMemosByAlarmId(alarmId: UUID) async throws -> [MemosEntity] { [] }
    public func getMemosByScheduleId(scheduleId: UUID) async throws -> [MemosEntity] { [] }
}

// MARK: - Mock LocalizationUseCase (for Example app DIContainer)
public final class MockLocalizationUseCaseForAlarms: LocalizationUseCase, @unchecked Sendable {
    public init() {}
    public func loadPreferredLanguage(userId: UUID) async throws -> LocalizationEntity? {
        LocalizationEntity(languageCode: "ko", languageLabel: "한국어")
    }
    public func savePreferredLanguage(userId: UUID, languageCode: String) async throws {}
    public func fetchLocalizationBundle() -> Bundle { .main }
    public func fetchAvailableLocalizations() async throws -> [LocalizationEntity] {
        [LocalizationEntity(languageCode: "ko", languageLabel: "한국어"), LocalizationEntity(languageCode: "en", languageLabel: "English")]
    }
}
