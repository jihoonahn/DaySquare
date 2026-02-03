import Foundation
import SwiftUI
import MainFeatureInterface
import SettingsFeatureInterface

public final class MockSettingFactory: SettingFactory, @unchecked Sendable {
    public init() {}
    public func makeInterface() -> SettingInterface {
        StubSettingInterface()
    }
    public func makeView() -> AnyView {
        AnyView(Text("Settings").padding())
    }
}

private final class StubSettingInterface: SettingInterface {
    var stateStream: AsyncStream<SettingState> {
        AsyncStream { continuation in
            continuation.yield(SettingState())
            continuation.finish()
        }
    }
    func send(_ action: SettingAction) {}
    func getCurrentState() -> SettingState { SettingState() }
}
