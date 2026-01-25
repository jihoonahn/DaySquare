import Foundation

public protocol LocalizationRepository: Sendable {
    func loadPreferredLanguage(userId: UUID) async throws -> LocalizationEntity?
    func savePreferredLanguage(_ entity: LocalizationEntity, for userId: UUID) async throws
    func fetchLocalizationBundle() -> Bundle
    func fetchAvailableLocalizations() async throws -> [LocalizationEntity]
}
