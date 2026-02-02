import Foundation
import LoginFeatureInterface
import UsersDomainInterface
import LocalizationDomainInterface

// MARK: - Mock UsersUseCase
public final class MockUsersUseCaseForLogin: UsersUseCase, @unchecked Sendable {
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

// MARK: - Mock LocalizationUseCase (for Example app DIContainer)
public final class MockLocalizationUseCaseForLogin: LocalizationUseCase, @unchecked Sendable {
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
