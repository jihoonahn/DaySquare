import SwiftUI
import Rex
import LoginFeature
import LoginFeatureInterface
import LoginFeatureTesting
import Dependency
import LocalizationDomainInterface
import UsersDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForLogin() }
        container.register(UsersUseCase.self) { MockUsersUseCaseForLogin() }
    }

    var body: some Scene {
        WindowGroup {
            LoginView(
                interface: LoginStore(
                    store: Store(
                        initialState: .init(),
                        reducer: LoginReducer(usersUseCase: MockUsersUseCaseForLogin())
                    )
                )
            )
        }
    }
}
