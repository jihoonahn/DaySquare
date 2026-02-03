import Foundation
import LocalizationDomainInterface

// MARK: - Mock LocalizationUseCase (SettingsFeature Tests용)
public final class MockLocalizationUseCaseForSettings: LocalizationUseCase, @unchecked Sendable {
    public init() {}

    public func loadPreferredLanguage(userId: UUID) async throws -> LocalizationEntity? {
        LocalizationEntity(languageCode: "ko", languageLabel: "한국어")
    }

    public func savePreferredLanguage(userId: UUID, languageCode: String) async throws {}

    public func fetchLocalizationBundle() -> Bundle {
        .main
    }

    public func fetchAvailableLocalizations() async throws -> [LocalizationEntity] {
        [
            LocalizationEntity(languageCode: "ko", languageLabel: "한국어"),
            LocalizationEntity(languageCode: "en", languageLabel: "English")
        ]
    }
}
