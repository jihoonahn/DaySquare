import Foundation
import SplashFeatureInterface
import LocalizationDomainInterface

/// Mock types and test doubles for SplashFeature unit tests.
public enum SplashFeatureTesting {}

// MARK: - Mock LocalizationUseCase (for Example app DIContainer)
public final class MockLocalizationUseCaseForSplash: LocalizationUseCase, @unchecked Sendable {
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
