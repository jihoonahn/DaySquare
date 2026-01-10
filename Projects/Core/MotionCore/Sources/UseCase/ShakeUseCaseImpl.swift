import Foundation
import ShakeDomainInterface

public final class ShakeUseCaseImpl: ShakeUseCase {

    private let repository: ShakeRepository
    
    public init(repository: ShakeRepository) {
        self.repository = repository
    }

    public func startMonitoring(for alarmId: UUID, executionId: UUID, requiredCount: Int) async throws {
        try await repository.startMonitoring(for: alarmId, executionId: executionId, requiredCount: requiredCount)
    }

    public func stopMonitoring(for alarmId: UUID) {
        repository.stopMonitoring(for: alarmId)
    }

    public func stopAllMonitoring() {
        repository.stopAllMonitoring()
    }
}
