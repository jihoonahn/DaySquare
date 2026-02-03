import Foundation
import SwiftUI
import MainFeatureInterface

public final class MockMainFactory: MainFactory, @unchecked Sendable {
    public init() {}
    public func makeInterface() -> MainInterface {
        StubMainInterface()
    }
    public func makeView() -> AnyView {
        AnyView(Text("Main").padding())
    }
}

private final class StubMainInterface: MainInterface {
    var stateStream: AsyncStream<MainState> {
        AsyncStream { continuation in
            continuation.yield(MainState())
            continuation.finish()
        }
    }
    func send(_ action: MainAction) {}
    func getCurrentState() -> MainState { MainState() }
}
