import SwiftUI
import Rex
import SettingsFeature
import SettingsFeatureInterface
import SettingsFeatureTesting
import Dependency
import LocalizationDomainInterface
import NotificationDomainInterface
import UsersDomainInterface

@main
struct ExampleApp: App {
    init() {
        // Example 앱은 AppDependencies.setup()을 호출하지 않으므로,
        // Localization 등에서 사용하는 UseCase들을 DIContainer에 등록
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForSettings() }
        container.register(NotificationUseCase.self) { MockNotificationUseCaseForSettings() }
        container.register(UsersUseCase.self) { MockUsersUseCaseForSettings() }
    }

    var body: some Scene {
        WindowGroup {
            SettingView(
                interface: SettingStore(
                    store: Store(
                        initialState: .init(),
                        reducer: SettingReducer(
                            usersUseCase: MockUsersUseCaseForSettings(),
                            localizationUseCase: MockLocalizationUseCaseForSettings(),
                            notificationUseCase: MockNotificationUseCaseForSettings()
                        )
                    )
                )
            )
        }
    }
}
