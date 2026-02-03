import Testing
import Rex
@testable import SplashFeature
import SplashFeatureInterface

struct SplashFeatureTests {

    @Test("SplashState 초기값")
    func splashStateInit() throws {
        let state = SplashState()
        #expect(state != nil)
    }

    @Test("SplashReducer reduce 시 항상 빈 이펙트 (showSplash 무처리)")
    func splashReducerReturnsEmptyEffects() throws {
        let reducer = SplashReducer()
        var state = SplashState()
        let effects = reducer.reduce(state: &state, action: .showSplash)
        #expect(effects.isEmpty)
    }
}
