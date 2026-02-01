import Testing
@testable import SupabaseCore
@testable import SupabaseCoreTesting
import UsersDomainInterface

struct SupabaseCoreTests {

    @Test("UsersUseCaseImpl getCurrentUser 호출 시 repository에 전달")
    func useCaseGetCurrentUserDelegatesToRepository() async throws {
        let mock = MockUsersRepositoryForSupabase()
        mock.fetchCurrentUserResult = SupabaseCoreTesting.makeUsersEntity()
        let useCase = UsersUseCaseImpl(userRepository: mock)
        let result = try await useCase.getCurrentUser()
        #expect(result?.email == "test@test.com")
    }

    @Test("UsersUseCaseImpl logout 호출 시 repository에 전달")
    func useCaseLogoutDelegatesToRepository() async throws {
        let mock = MockUsersRepositoryForSupabase()
        let useCase = UsersUseCaseImpl(userRepository: mock)
        try await useCase.logout()
        #expect(mock.logoutCalled == true)
    }

    @Test("UsersUseCaseImpl updateUser 호출 시 repository에 전달")
    func useCaseUpdateUserDelegatesToRepository() async throws {
        let mock = MockUsersRepositoryForSupabase()
        let useCase = UsersUseCaseImpl(userRepository: mock)
        try await useCase.updateUser(SupabaseCoreTesting.makeUsersEntity())
        #expect(mock.saveUserCalled == true)
    }
}
