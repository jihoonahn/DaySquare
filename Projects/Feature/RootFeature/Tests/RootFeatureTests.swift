import Testing
import Rex
@testable import RootFeature
import RootFeatureInterface
import RootFeatureTesting

struct RootFeatureTests {

    @Test("switchToLogin 시 flow .login")
    func switchToLogin() throws {
        let reducer = RootReducer(usersUseCase: MockUsersUseCaseForRoot())
        var state = RootState()
        state.flow = .main
        _ = reducer.reduce(state: &state, action: .switchToLogin)
        #expect(state.flow == .login)
    }

    @Test("switchToMain 시 flow .main")
    func switchToMain() throws {
        let reducer = RootReducer(usersUseCase: MockUsersUseCaseForRoot())
        var state = RootState()
        state.flow = .login
        _ = reducer.reduce(state: &state, action: .switchToMain)
        #expect(state.flow == .main)
    }

    @Test("RootState 초기 flow .splash")
    func rootStateInitialFlow() throws {
        let state = RootState()
        #expect(state.flow == .splash)
    }

    @Test("checkAutoLogin 시 이펙트 반환 (비동기)")
    func checkAutoLoginReturnsEffect() throws {
        let reducer = RootReducer(usersUseCase: MockUsersUseCaseForRoot())
        var state = RootState()
        let effects = reducer.reduce(state: &state, action: .checkAutoLogin)
        #expect(!effects.isEmpty)
    }
}
