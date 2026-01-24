import SwiftUI
import Rex
import HomeFeatureInterface
import MemosDomainInterface
import UsersDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import NotificationCoreInterface
import Dependency

public struct HomeFactoryImpl: HomeFactory {
    private let store: Store<HomeReducer>
    
    public init(store: Store<HomeReducer>) {
        self.store = store
    }

    public func makeInterface() -> HomeInterface {
        return HomeStore(store: store)
    }
    
    public func makeView() -> AnyView {
        let interface = makeInterface()
        return AnyView(HomeView(interface: interface))
    }
}

public extension HomeFactoryImpl {
    static func create() -> HomeFactoryImpl {
        let container = DIContainer.shared
        let reducer = HomeReducer(
            memosUseCase: container.resolve(MemosUseCase.self),
            usersUseCase: container.resolve(UsersUseCase.self),
            alarmsUseCase: container.resolve(AlarmsUseCase.self),
            schedulesUseCase: container.resolve(SchedulesUseCase.self),
            notificationService: container.resolve(NotificationService.self)
        )
        let store = Store<HomeReducer>(
            initialState: HomeState(),
            reducer: reducer
        )
        return HomeFactoryImpl(store: store)
    }
    
    static func create(initialState: HomeState) -> HomeFactoryImpl {
        let container = DIContainer.shared
        let reducer = HomeReducer(
            memosUseCase: container.resolve(MemosUseCase.self),
            usersUseCase: container.resolve(UsersUseCase.self),
            alarmsUseCase: container.resolve(AlarmsUseCase.self),
            schedulesUseCase: container.resolve(SchedulesUseCase.self),
            notificationService: container.resolve(NotificationService.self)
        )
        let store = Store<HomeReducer>(
            initialState: initialState,
            reducer: reducer
        )
        return HomeFactoryImpl(store: store)
    }
}

