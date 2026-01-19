import Foundation
import ShakeDomainInterface

public enum ShakeServiceError: Error {
    case accelerometerNotAvailable
    case monitoringNotStarted
    case monitoringStopped
}

public protocol ShakeService: Sendable {
    func startMonitoring(for alarmId: UUID, executionId: UUID, requiredCount: Int) async throws
    func stopMonitoring(for alarmId: UUID)
    func stopAllMonitoring()
    func getShakeCount(for alarmId: UUID) -> Int
}
