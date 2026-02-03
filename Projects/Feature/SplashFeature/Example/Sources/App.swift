import SwiftUI
import Rex
import SplashFeature
import SplashFeatureInterface
import SplashFeatureTesting
import Dependency

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView(interface: SplashStore(store: Store(initialState: .init(), reducer: .init())))
        }
    }
}
