import Foundation
import SwiftUI
import LoginFeatureInterface

public final class MockLoginFactory: LoginFactory, @unchecked Sendable {
    public init() {}
    public func makeInterface() -> LoginInterface {
        StubLoginInterface()
    }
    public func makeView() -> AnyView {
        AnyView(Text("Login").padding())
    }
}

private final class StubLoginInterface: LoginInterface {
    var stateStream: AsyncStream<LoginState> {
        AsyncStream { continuation in
            continuation.yield(LoginState())
            continuation.finish()
        }
    }
    func send(_ action: LoginAction) {}
    func getCurrentState() -> LoginState { LoginState() }
}
