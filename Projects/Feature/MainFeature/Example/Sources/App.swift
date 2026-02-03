import SwiftUI
import Rex
import MainFeature
import MainFeatureInterface
import MainFeatureTesting
import HomeFeatureInterface
import SettingsFeatureInterface
import Dependency
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
        container.register(HomeFactory.self) { MockHomeFactory() }
        container.register(SettingFactory.self) { MockSettingFactory() }
    }

    var body: some Scene {
        WindowGroup {
            MainView(
                interface: MainStore(
                    store: Store(
                        initialState: .init(),
                        reducer: .init())
                )
            )
        }
    }
}
