import Foundation
import SwiftUI
import SplashFeatureInterface

public final class MockSplashFactory: SplashFactory, @unchecked Sendable {
    public init() {}
    public func makeInterface() -> SplashInterface {
        StubSplashInterface()
    }
    public func makeView() -> AnyView {
        AnyView(Text("Splash").padding())
    }
}

private final class StubSplashInterface: SplashInterface {
    var stateStream: AsyncStream<SplashState> {
        AsyncStream { continuation in
            continuation.yield(SplashState())
            continuation.finish()
        }
    }
    func send(_ action: SplashAction) {}
    func getCurrentState() -> SplashState { SplashState() }
}
