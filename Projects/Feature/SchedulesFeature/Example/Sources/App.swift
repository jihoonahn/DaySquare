import SwiftUI
import Rex
import SchedulesFeature
import SchedulesFeatureInterface
import SchedulesFeatureTesting
import Dependency
import LocalizationDomainInterface
import UsersDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForSchedules() }
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
