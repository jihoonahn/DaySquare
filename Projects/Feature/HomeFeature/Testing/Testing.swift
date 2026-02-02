import Foundation
import HomeFeatureInterface
import MemosDomainInterface
import UsersDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import NotificationCoreInterface
import LocalizationDomainInterface

// MARK: - Mock UsersUseCase
public final class MockUsersUseCaseForHome: UsersUseCase, @unchecked Sendable {
    public var getCurrentUserResult: UsersEntity?
    public init() {}
    public func login(provider: String, email: String?, displayName: String?) async throws {}
    public func updateUser(_ user: UsersEntity) async throws {}
    public func getCurrentUser() async throws -> UsersEntity? {
        getCurrentUserResult ?? UsersEntity(
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
public final class MockMemosUseCaseForHome: MemosUseCase, @unchecked Sendable {
    public init() {}
    public func createMemo(_ memo: MemosEntity) async throws {}
    public func updateMemo(_ memo: MemosEntity) async throws {}
    public func deleteMemo(id: UUID) async throws {}
    public func getMemo(id: UUID) async throws -> MemosEntity { fatalError() }
    public func getMemos(userId: UUID) async throws -> [MemosEntity] { [] }
    public func searchMemos(userId: UUID, keyword: String) async throws -> [MemosEntity] { [] }
    public func getMemosByAlarmId(alarmId: UUID) async throws -> [MemosEntity] { [] }
    public func getMemosByScheduleId(scheduleId: UUID) async throws -> [MemosEntity] { [] }
}

// MARK: - Mock AlarmsUseCase
public final class MockAlarmsUseCaseForHome: AlarmsUseCase, @unchecked Sendable {
    public init() {}
    public func fetchAll(userId: UUID) async throws -> [AlarmsEntity] { [] }
    public func create(_ alarm: AlarmsEntity) async throws {}
    public func update(_ alarm: AlarmsEntity) async throws {}
    public func delete(alarmId: UUID) async throws {}
    public func toggle(alarmId: UUID, isEnabled: Bool) async throws {}
}

// MARK: - Mock SchedulesUseCase
public final class MockSchedulesUseCaseForHome: SchedulesUseCase, @unchecked Sendable {
    public init() {}
    public func getSchedules(userId: UUID) async throws -> [SchedulesEntity] { [] }
    public func getSchedule(id: UUID) async throws -> SchedulesEntity { fatalError() }
    public func createSchedule(_ schedule: SchedulesEntity) async throws {}
    public func updateSchedule(_ schedule: SchedulesEntity) async throws {}
    public func deleteSchedule(id: UUID) async throws {}
}

// MARK: - Mock AlarmSchedulesUseCase
public final class MockAlarmSchedulesUseCaseForHome: AlarmSchedulesUseCase, @unchecked Sendable {
    public init() {}
    public func scheduleAlarm(_ alarm: AlarmsEntity) async throws {}
    public func cancelAlarm(_ alarmId: UUID) async throws {}
    public func updateAlarm(_ alarm: AlarmsEntity) async throws {}
    public func toggleAlarm(_ alarmId: UUID, isEnabled: Bool) async throws {}
    public func stopAlarm(_ alarmId: UUID) async throws {}
}

// MARK: - Mock NotificationService
public final class MockNotificationServiceForHome: NotificationService, @unchecked Sendable {
    public init() {}
    public func saveIsEnabled(_ isEnabled: Bool) async throws {}
    public func loadIsEnabled() async throws -> Bool? { true }
    public func updatePermissions(enabled: Bool) async {}
    public func scheduleNotifications(for schedules: [SchedulesEntity]) async {}
    public func clearScheduleNotifications() async {}
}

// MARK: - Mock LocalizationUseCase (for Example app DIContainer)
public final class MockLocalizationUseCaseForHome: LocalizationUseCase, @unchecked Sendable {
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
