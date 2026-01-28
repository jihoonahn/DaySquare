import Foundation

public protocol AppleOauthRepository: Sendable {
    func signInWithApple() async throws -> AppleOauthEntity
    func signOut() async throws
}
