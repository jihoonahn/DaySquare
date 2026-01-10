import Foundation
import Rex
import ShakeDomainInterface
import Utility

public struct ShakeState: StateType {
    public var shakeCount: Int
    public var requiredCount: Int
    public var alarmId: UUID?
    public var executionId: UUID?
    public var isMonitoring: Bool
    
    public init(
        shakeCount: Int = 0,
        requiredCount: Int = 3,
        alarmId: UUID? = nil,
        executionId: UUID? = nil,
        isMonitoring: Bool = false
    ) {
        self.shakeCount = shakeCount
        self.requiredCount = requiredCount
        self.alarmId = alarmId
        self.executionId = executionId
        self.isMonitoring = isMonitoring
    }
}
