import Testing
import Rex
@testable import LoginFeature
import LoginFeatureInterface
import LoginFeatureTesting

struct LoginFeatureTests {

    @Test("loginSuccess 시 isLoading false, isLoggedIn true")
    func loginSuccessUpdatesState() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        state.isLoading = true
        _ = reducer.reduce(state: &state, action: .loginSuccess)
        #expect(state.isLoading == false)
        #expect(state.isLoggedIn == true)
    }

    @Test("loginFailure 시 isLoading false, isLoggedIn false")
    func loginFailureUpdatesState() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        state.isLoading = true
        state.isLoggedIn = true
        _ = reducer.reduce(state: &state, action: .loginFailure)
        #expect(state.isLoading == false)
        #expect(state.isLoggedIn == false)
    }

    @Test("toggleLoading(true) 시 isLoading true")
    func toggleLoadingTrue() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        _ = reducer.reduce(state: &state, action: .toggleLoading(true))
        #expect(state.isLoading == true)
    }

    @Test("toggleLoading(false) 시 isLoading false")
    func toggleLoadingFalse() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        state.isLoading = true
        _ = reducer.reduce(state: &state, action: .toggleLoading(false))
        #expect(state.isLoading == false)
    }

    @Test("selectToAppleOauth 시 isLoading true")
    func selectToAppleOauthSetsLoading() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        _ = reducer.reduce(state: &state, action: .selectToAppleOauth)
        #expect(state.isLoading == true)
    }

    @Test("selectToGoogleOauth 시 isLoading true")
    func selectToGoogleOauthSetsLoading() throws {
        let reducer = LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
        var state = LoginState()
        _ = reducer.reduce(state: &state, action: .selectToGoogleOauth)
        #expect(state.isLoading == true)
    }
}
