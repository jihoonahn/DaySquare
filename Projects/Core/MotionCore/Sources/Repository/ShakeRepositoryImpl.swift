import Foundation
import MotionCoreInterface
import ShakeDomainInterface

public final class ShakeRepositoryImpl: ShakeRepository {

    private let service: ShakeService

    public init(service: ShakeService) {
        self.service = service
    }

    public func startMonitoring(for alarmId: UUID, executionId: UUID, requiredCount: Int) async throws {
        try await service.startMonitoring(for: alarmId, executionId: executionId, requiredCount: requiredCount)
    }

    public func stopMonitoring(for alarmId: UUID) {
        service.stopMonitoring(for: alarmId)
    }

    public func stopAllMonitoring() {
        service.stopAllMonitoring()
    }
}
