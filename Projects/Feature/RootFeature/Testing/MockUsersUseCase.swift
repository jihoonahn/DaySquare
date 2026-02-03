import Foundation
import RootFeatureInterface
import UsersDomainInterface

public final class MockUsersUseCase: UsersUseCase, @unchecked Sendable {
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
