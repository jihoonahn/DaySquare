import Foundation
import AlarmsDomainInterface
import Dependency

public final class AlarmUseCaseImpl: AlarmsUseCase {
    private let alarmRepository: AlarmsRepository

    public init(alarmRepository: AlarmsRepository) {
        self.alarmRepository = alarmRepository
    }
    
    public func fetchAll(userId: UUID) async throws -> [AlarmsEntity] {
        return try await alarmRepository.fetchAlarms(userId: userId)
    }
    
    public func create(_ alarm: AlarmsEntity) async throws {
        try await alarmRepository.createAlarm(alarm)
    }
    
    public func update(_ alarm: AlarmsEntity) async throws {
        try await alarmRepository.updateAlarm(alarm)
    }
    
    public func delete(id: UUID) async throws {
        try await alarmRepository.deleteAlarm(alarmId: id)
    }
    
    public func toggle(id: UUID, isEnabled: Bool) async throws {
        try await alarmRepository.toggleAlarm(alarmId: id, isEnabled: isEnabled)
    }
}
