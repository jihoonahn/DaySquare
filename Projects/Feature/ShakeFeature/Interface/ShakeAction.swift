import Foundation
import Rex
import ShakeDomainInterface

public enum ShakeAction: ActionType {
    case viewAppear
    case startMonitoring(alarmId: UUID, executionId: UUID, requiredCount: Int)
    case shakeDetected(count: Int, shakeData: ShakeEntity?)
    case stopMonitoring
    case alarmStopped(alarmId: UUID)
}
