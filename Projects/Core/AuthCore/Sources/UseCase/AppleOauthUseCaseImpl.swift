import Foundation
import AuthDomainInterface

public final class AppleOauthUseCaseImpl: AppleOauthUseCase {
    
    private let appleOauthRepository: AppleOauthRepository
    
    public init(appleOauthRepository: AppleOauthRepository) {
        self.appleOauthRepository = appleOauthRepository
    }
    
    public func signInWithApple() async throws -> AppleOauthEntity {
        return try await appleOauthRepository.signInWithApple()
    }
    
    public func signOut() async throws {
        try await appleOauthRepository.signOut()
    }
}
