import SwiftUI
import Rex
import SplashFeature
import SplashFeatureInterface
import SplashFeatureTesting
import Dependency
import LocalizationDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForSplash() }
    }

    var body: some Scene {
        WindowGroup {
            SplashView(interface: SplashStore(store: Store(initialState: .init(), reducer: .init())))
        }
    }
}
