import SwiftUI
import Rex
import ShakeFeatureInterface
import ShakeDomainInterface
import MotionCoreInterface
import UsersDomainInterface
import AlarmsDomainInterface
import AlarmExecutionsDomainInterface
import Dependency

public struct ShakeFactoryImpl: ShakeFactory {
    private let store: Store<ShakeReducer>
    
    public init(store: Store<ShakeReducer>) {
        self.store = store
    }

    public func makeInterface() -> ShakeInterface {
        return ShakeStore(store: store)
    }
    
    public func makeView() -> AnyView {
        let interface = makeInterface()
        return AnyView(ShakeView(interface: interface))
    }
}

public extension ShakeFactoryImpl {
    static func create(
        usersUseCase: UsersUseCase,
        shakeUseCase: ShakeUseCase,
        alarmSchedulesUseCase: AlarmSchedulesUseCase,
        alarmExecutionsUseCase: AlarmExecutionsUseCase
    ) -> ShakeFactoryImpl {
        let store = Store<ShakeReducer>(
            initialState: ShakeState(),
            reducer: ShakeReducer(
                usersUseCase: usersUseCase,
                alarmSchedulesUseCase: alarmSchedulesUseCase,
                alarmExecutionsUseCase: alarmExecutionsUseCase,
                shakeUseCase: shakeUseCase
            )
        )
        return ShakeFactoryImpl(store: store)
    }
    
    static func create(
        initialState: ShakeState,
        usersUseCase: UsersUseCase,
        shakeUseCase: ShakeUseCase,
        alarmSchedulesUseCase: AlarmSchedulesUseCase,
        alarmExecutionsUseCase: AlarmExecutionsUseCase
    ) -> ShakeFactoryImpl {
        let store = Store<ShakeReducer>(
            initialState: initialState,
            reducer: ShakeReducer(
                usersUseCase: usersUseCase,
                alarmSchedulesUseCase: alarmSchedulesUseCase,
                alarmExecutionsUseCase: alarmExecutionsUseCase,
                shakeUseCase: shakeUseCase
            )
        )
        return ShakeFactoryImpl(store: store)
    }
}
