import Foundation
import AuthDomainInterface
import AuthCoreInterface

public final class AppleOauthRepositoryImpl: AppleOauthRepository {
    
    private let appleOauthService: AppleOauthService
    
    public init(appleOauthService: AppleOauthService) {
        self.appleOauthService = appleOauthService
    }
    
    public func signInWithApple() async throws -> AppleOauthEntity {
        return try await appleOauthService.signInWithApple()
    }
    
    public func signOut() async throws {
        try await appleOauthService.signOut()
    }
}
