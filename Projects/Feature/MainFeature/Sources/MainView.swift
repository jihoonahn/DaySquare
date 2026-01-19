import SwiftUI
import Rex
import MainFeatureInterface
import HomeFeatureInterface
import AlarmsFeatureInterface
import SchedulesFeatureInterface
import SettingsFeatureInterface
import ShakeFeatureInterface
import Dependency
import RefineUIIcons
import Designsystem

public struct MainView: View {
    let interface: MainInterface
    @State private var state = MainState()

    private let homeFactory: HomeFactory
    private let alarmsFactory: AlarmFactory
    private let schedulesFactory: SchedulesFactory
    private let settingsFactory: SettingFactory

    public init(
        interface: MainInterface
    ) {
        self.interface = interface
        self.homeFactory = DIContainer.shared.resolve(HomeFactory.self)
        self.alarmsFactory = DIContainer.shared.resolve(AlarmFactory.self)
        self.schedulesFactory = DIContainer.shared.resolve(SchedulesFactory.self)
        self.settingsFactory = DIContainer.shared.resolve(SettingFactory.self)
    }
    
    public var body: some View {
        ZStack {
            homeFactory.makeView()
            VStack(spacing: 0) {
                Spacer()
                TabBar(
                    items: tabBarItems,
                    haptic: true
                )
            }
        }
        .sheet(item: Binding(
            get: { state.sheetFlow },
            set: { newFlow in
                interface.send(.showSheetFlow(newFlow))
            }
        )) { _ in
            switch state.sheetFlow {
            case .alarm:
                alarmsFactory.makeView()
            case .schedule:
                schedulesFactory.makeView()
            case .settings:
                settingsFactory.makeView()
            case .none:
                EmptyView()
            }
        }
        .ignoresSafeArea()
        .task {
            for await newState in interface.stateStream {
                await MainActor.run {
                    self.state = newState
                }
            }
        }
    }
    
    private var tabBarItems: [TabBarItem<MainState.SheetFlow>] {
        MainState.SheetFlow.allCases.map { flow in
            TabBarItem(
                identifier: flow,
                icon: flow.icon,
                action: {
                    if state.sheetFlow == flow {
                        interface.send(.showSheetFlow(nil))
                    } else {
                        interface.send(.showSheetFlow(flow))
                    }
                }
            )
        }
    }
}
