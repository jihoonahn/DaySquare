import Testing
import Rex
@testable import MainFeature
import MainFeatureInterface

struct MainFeatureTests {

    @Test("selectTab(.home) 시 selectedTab .home")
    func selectTabHome() throws {
        let reducer = MainReducer()
        var state = MainState()
        state.selectedTab = .settings
        _ = reducer.reduce(state: &state, action: .selectTab(.home))
        #expect(state.selectedTab == .home)
    }

    @Test("selectTab(.settings) 시 selectedTab .settings")
    func selectTabSettings() throws {
        let reducer = MainReducer()
        var state = MainState()
        #expect(state.selectedTab == .home)
        _ = reducer.reduce(state: &state, action: .selectTab(.settings))
        #expect(state.selectedTab == .settings)
    }

    @Test("MainState.Tab title 검증")
    func tabTitles() throws {
        #expect(MainState.Tab.home.title == "홈")
        #expect(MainState.Tab.settings.title == "설정")
    }
}
