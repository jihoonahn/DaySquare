import SwiftUI
import Rex
import HomeFeature
import HomeFeatureInterface
import HomeFeatureTesting
import Dependency
import LocalizationDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForHome() }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                interface: HomeStore(
                    store: Store(
                        initialState: .init(),
                        reducer: HomeReducer(
                            memosUseCase: MockMemosUseCaseForHome(),
                            usersUseCase: MockUsersUseCaseForHome(),
                            alarmsUseCase: MockAlarmsUseCaseForHome(),
                            schedulesUseCase: MockSchedulesUseCaseForHome(),
                            notificationService: MockNotificationServiceForHome()
                        )
                    )
                )
            )
        }
    }
}
