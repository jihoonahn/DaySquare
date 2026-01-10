import SwiftUI
import Rex

public protocol ShakeFactory {
    func makeInterface() -> ShakeInterface
    func makeView() -> AnyView
}
