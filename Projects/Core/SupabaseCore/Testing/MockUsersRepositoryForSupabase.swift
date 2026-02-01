import Foundation
import SupabaseCoreInterface
import UsersDomainInterface

// MARK: - Mock UsersRepository (SupabaseCore UseCase 테스트용)
public final class MockUsersRepositoryForSupabase: UsersRepository, @unchecked Sendable {
    public var fetchCurrentUserResult: UsersEntity?
    public var fetchCurrentUserError: Error?
    public var loginWithOAuthCalled = false
    public var saveUserCalled = false
    public var deleteUserCalled = false
    public var logoutCalled = false

    public init() {}

    public func fetchCurrentUser() async throws -> UsersEntity? {
        if let error = fetchCurrentUserError { throw error }
        return fetchCurrentUserResult
    }

    public func loginWithOAuth(provider: String, email: String?, displayName: String?) async throws {
        loginWithOAuthCalled = true
    }

    public func saveUser(_ user: UsersEntity) async throws {
        saveUserCalled = true
    }

    public func deleteUser() async throws {
        deleteUserCalled = true
    }

    public func logout() async throws {
        logoutCalled = true
    }
}

// MARK: - Test Fixtures
public enum SupabaseCoreTesting {
    public static func makeUsersEntity() -> UsersEntity {
        let now = Date()
        return UsersEntity(
            id: UUID(),
            provider: "apple",
            email: "test@test.com",
            displayName: "Test",
            createdAt: now,
            updatedAt: now
        )
    }
}
