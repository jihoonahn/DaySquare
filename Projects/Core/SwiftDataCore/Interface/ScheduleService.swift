import Foundation
import SchedulesDomainInterface

@MainActor
public protocol SchedulesService {
    func getSchedules(userId: UUID) async throws -> [SchedulesEntity]
    func getSchedule(id: UUID) async throws -> SchedulesEntity
    func createSchedule(_ schedule: SchedulesEntity) async throws
    func updateSchedule(_ schedule: SchedulesEntity) async throws
    func deleteSchedule(id: UUID) async throws
}
