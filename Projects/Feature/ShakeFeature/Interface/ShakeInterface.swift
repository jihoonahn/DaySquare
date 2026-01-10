import Rex

public protocol ShakeInterface {
    var stateStream: AsyncStream<ShakeState> { get }
    func send(_ action: ShakeAction)
    func getCurrentState() -> ShakeState
}
