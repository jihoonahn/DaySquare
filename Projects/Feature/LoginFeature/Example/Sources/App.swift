import SwiftUI
import Rex
import LoginFeature
import LoginFeatureInterface
import LoginFeatureTesting
import Dependency
import LocalizationDomainInterface
import LocalizationCoreInterface
import LocalizationCore
import UsersDomainInterface

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
