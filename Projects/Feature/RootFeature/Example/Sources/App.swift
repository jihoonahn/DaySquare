import SwiftUI
import Rex
import RootFeature
import RootFeatureInterface
import RootFeatureTesting
import SplashFeatureInterface
import LoginFeatureInterface
import MainFeatureInterface
import Dependency
import UsersDomainInterface
import LocalizationDomainInterface
import LocalizationCoreInterface
import LocalizationCore

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationService.self) { LocalizationCore.LocalizationServiceImpl() }
        container.register(LocalizationRepository.self) {
            LocalizationCore.LocalizationRepositoryImpl(service: container.resolve(LocalizationService.self))
        }
        container.register(LocalizationUseCase.self) {
            LocalizationCore.LocalizationUseCaseImpl(repository: container.resolve(LocalizationRepository.self))
        }
        container.register(UsersUseCase.self) { MockUsersUseCase() }
        container.register(SplashFactory.self) { MockSplashFactory() }
        container.register(LoginFactory.self) { MockLoginFactory() }
        container.register(MainFactory.self) { MockMainFactory() }
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                interface: RootStore(
                    store: Store(
                        initialState: .init(),
                        reducer: .init(usersUseCase: DIContainer.shared.resolve(UsersUseCase.self))
                    )
                )
            )
        }
    }
}
