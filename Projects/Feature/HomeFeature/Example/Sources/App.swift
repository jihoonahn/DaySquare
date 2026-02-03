import SwiftUI
import Rex
import HomeFeature
import HomeFeatureInterface
import HomeFeatureTesting
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
                            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForHome(),
                            notificationService: MockNotificationServiceForHome()
                        )
                    )
                )
            )
        }
    }
}
