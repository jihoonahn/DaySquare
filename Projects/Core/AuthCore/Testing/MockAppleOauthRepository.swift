import Foundation
import AuthCoreInterface
import AuthDomainInterface

// MARK: - Mock AppleOauthRepository
public final class MockAppleOauthRepository: AppleOauthRepository, @unchecked Sendable {
    public var signInWithAppleResult: Result<AppleOauthEntity, Error>?
    public var signInWithAppleCalled = false
    public var signOutCalled = false

    public init() {}

    public func signInWithApple() async throws -> AppleOauthEntity {
        signInWithAppleCalled = true
        guard let result = signInWithAppleResult else {
            return AppleOauthEntity(identityToken: "test-token")
        }
        return try result.get()
    }

    public func signOut() async throws {
        signOutCalled = true
    }
}

// MARK: - Test Fixtures
public enum AuthCoreTesting {
    public static func makeAppleOauthEntity() -> AppleOauthEntity {
        AppleOauthEntity(
            email: "test@test.com",
            displayName: "Test",
            identityToken: "test-token",
            authorizationCode: "code"
        )
    }
}
