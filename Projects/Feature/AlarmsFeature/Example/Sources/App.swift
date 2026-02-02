import SwiftUI
import Rex
import AlarmsFeature
import AlarmsFeatureInterface
import AlarmsFeatureTesting
import Dependency
import LocalizationDomainInterface
import UsersDomainInterface

@main
struct ExampleApp: App {
    init() {
        let container = DIContainer.shared
        container.register(LocalizationUseCase.self) { MockLocalizationUseCaseForAlarms() }
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
