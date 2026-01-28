import Foundation
import AuthDomainInterface

public protocol AppleOauthService: Sendable {
    func signInWithApple() async throws -> AppleOauthEntity
    func signOut() async throws
}
