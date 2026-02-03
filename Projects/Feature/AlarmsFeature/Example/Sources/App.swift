import SwiftUI
import Rex
import AlarmsFeature
import AlarmsFeatureInterface
import AlarmsFeatureTesting
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
        container.register(UsersUseCase.self) { MockUsersUseCaseForAlarms() }
    }

    var body: some Scene {
        WindowGroup {
            AlarmView(
                interface: AlarmStore(
                    store: Store(
                        initialState: .init(),
                        reducer: AlarmReducer(
                            alarmsUseCase: MockAlarmsUseCaseForFeature(),
                            alarmSchedulesUseCase: MockAlarmSchedulesUseCaseForFeature(),
                            usersUseCase: MockUsersUseCaseForAlarms(),
                            memosUseCase: MockMemosUseCaseForAlarms()
                        )
                    )
                )
            )
        }
    }
}
