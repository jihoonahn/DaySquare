import Foundation
import SwiftUI
import MainFeatureInterface
import HomeFeatureInterface

public final class MockHomeFactory: HomeFactory, @unchecked Sendable {
    public init() {}
    public func makeInterface() -> HomeInterface {
        StubHomeInterface()
    }
    public func makeView() -> AnyView {
        AnyView(Text("Home").padding())
    }
}

private final class StubHomeInterface: HomeInterface {
    var stateStream: AsyncStream<HomeState> {
        AsyncStream { continuation in
            continuation.yield(HomeState())
            continuation.finish()
        }
    }
    func send(_ action: HomeAction) {}
    func getCurrentState() -> HomeState { HomeState() }
}
