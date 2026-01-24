import SwiftUI
import Rex
import MainFeatureInterface
import HomeFeatureInterface
import SettingsFeatureInterface
import Dependency
import RefineUIIcons
import Designsystem

public struct MainView: View {
    let interface: MainInterface
    @State private var state = MainState()

    private let homeFactory: HomeFactory
    private let settingsFactory: SettingFactory

    public init(
        interface: MainInterface
    ) {
        self.interface = interface
        self.homeFactory = DIContainer.shared.resolve(HomeFactory.self)
        self.settingsFactory = DIContainer.shared.resolve(SettingFactory.self)
    }
    
    public var body: some View {
        TabView(selection: Binding(
            get: { state.selectedTab },
            set: { newTab in
                interface.send(.selectTab(newTab))
            }
        )) {
            homeFactory.makeView()
                .tabItem {
                    Image(refineUIIcon: .home32Regular)
                }
                .tag(MainState.Tab.home)

            settingsFactory.makeView()
                .tabItem {
                    Image(refineUIIcon: .settings32Regular)
                }
                .tag(MainState.Tab.settings)
        }
        .tint(.green)
        .task {
            for await newState in interface.stateStream {
                await MainActor.run {
                    self.state = newState
                }
            }
        }
    }
}
