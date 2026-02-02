import Foundation
import UsersDomainInterface

// MARK: - Mock UsersUseCase
public final class MockUsersUseCaseForSettings: UsersUseCase, @unchecked Sendable {
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
            displayName: "Example User",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    public func deleteUser() async throws {}
    public func logout() async throws {}
}

