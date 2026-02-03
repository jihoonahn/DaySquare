import Foundation
import LocalizationDomainInterface

/// Mock types and test doubles for BaseFeature unit tests.
public enum BaseFeatureTesting {}

/// 단위 테스트용 Mock (LocalizationUseCase)
public final class MockLocalizationUseCase: LocalizationUseCase, @unchecked Sendable {
    public init() {}
    public func loadPreferredLanguage(userId: UUID) async throws -> LocalizationEntity? {
        LocalizationEntity(languageCode: "ko", languageLabel: "한국어")
    }
    public func savePreferredLanguage(userId: UUID, languageCode: String) async throws {}
    public func fetchLocalizationBundle() -> Bundle { .main }
    public func fetchAvailableLocalizations() async throws -> [LocalizationEntity] {
        [LocalizationEntity(languageCode: "ko", languageLabel: "한국어"), LocalizationEntity(languageCode: "en", languageLabel: "English")]
    }
}
