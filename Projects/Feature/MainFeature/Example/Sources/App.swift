import SwiftUI
import Rex
import MainFeature
import MainFeatureInterface
import HomeFeature
import SettingsFeature
import HomeFeatureTesting
import SettingsFeatureTesting
import Dependency
import LocalizationDomainInterface
import NotificationDomainInterface
import UsersDomainInterface
import MemosDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import NotificationCoreInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(UsersUseCase.self) { MockUsersUseCaseForHome() }
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForSettings() }
        container.register(NotificationUseCase.self) { MockNotificationUseCaseForSettings() }
        container.register(MemosUseCase.self) { MockMemosUseCaseForHome() }
        container.register(AlarmsUseCase.self) { MockAlarmsUseCaseForHome() }
        container.register(SchedulesUseCase.self) { MockSchedulesUseCaseForHome() }
        container.register(NotificationService.self) { MockNotificationServiceForHome() }
        container.register(HomeFactory.self) { HomeFactoryImpl.create() }
        container.register(SettingFactory.self) { SettingFactoryImpl.create() }
    }

    var body: some Scene {
        WindowGroup {
            MainView(interface: MainStore(store: Store(initialState: .init(), reducer: .init())))
        }
    }
}
