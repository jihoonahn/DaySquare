import SwiftUI
import Rex
import SchedulesFeature
import SchedulesFeatureInterface
import SchedulesFeatureTesting
import Dependency
import LocalizationDomainInterface
import LocalizationCoreInterface
import LocalizationCore
import UsersDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationService.self) {
            LocalizationCore.LocalizationServiceImpl()
        }
        container.register(LocalizationRepository.self) {
            LocalizationCore.LocalizationRepositoryImpl(service: container.resolve(LocalizationService.self))
        }
        container.register(LocalizationUseCase.self) {
            LocalizationCore.LocalizationUseCaseImpl(repository: container.resolve(LocalizationRepository.self))
        }
        container.register(UsersUseCase.self) { MockUsersUseCaseForFeature() }
    }

    var body: some Scene {
        WindowGroup {
            SchedulesView(
                interface: SchedulesStore(
                    store: Store(
                        initialState: .init(),
                        reducer: SchedulesReducer(
                            schedulesUseCase: MockSchedulesUseCaseForFeature(),
                            usersUseCase: MockUsersUseCaseForFeature(),
                            memosUseCase: MockMemosUseCaseForFeature()
                        )
                    )
                )
            )
        }
    }
}
