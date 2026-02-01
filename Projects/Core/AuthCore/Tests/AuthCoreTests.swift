import Testing
@testable import AuthCore
@testable import AuthCoreTesting
import AuthDomainInterface

struct AuthCoreTests {

    @Test("AppleOauthUseCaseImpl signInWithApple 호출 시 repository에 전달")
    func useCaseSignInDelegatesToRepository() async throws {
        let mock = MockAppleOauthRepository()
        mock.signInWithAppleResult = .success(AuthCoreTesting.makeAppleOauthEntity())
        let useCase = AppleOauthUseCaseImpl(appleOauthRepository: mock)
        let result = try await useCase.signInWithApple()
        #expect(mock.signInWithAppleCalled == true)
        #expect(result.identityToken == "test-token")
    }

    @Test("AppleOauthUseCaseImpl signOut 호출 시 repository에 전달")
    func useCaseSignOutDelegatesToRepository() async throws {
        let mock = MockAppleOauthRepository()
        let useCase = AppleOauthUseCaseImpl(appleOauthRepository: mock)
        try await useCase.signOut()
        #expect(mock.signOutCalled == true)
    }
}
