import Foundation

public protocol AppleOauthUseCase: Sendable {
    func signInWithApple() async throws -> AppleOauthEntity
    func signOut() async throws
}
