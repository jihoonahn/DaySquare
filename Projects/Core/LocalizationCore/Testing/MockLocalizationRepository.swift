import Foundation
import LocalizationCoreInterface
import LocalizationDomainInterface

// MARK: - Mock LocalizationRepository
public final class MockLocalizationRepository: LocalizationRepository, @unchecked Sendable {
    public var loadPreferredLanguageResult: LocalizationEntity?
    public var loadPreferredLanguageError: Error?
    public var savePreferredLanguageCalled = false
    public var fetchAvailableLocalizationsResult: [LocalizationEntity] = []
    public var fetchLocalizationBundleResult = Bundle.main

    public init() {}

    public func loadPreferredLanguage(userId: UUID) async throws -> LocalizationEntity? {
        if let error = loadPreferredLanguageError { throw error }
        return loadPreferredLanguageResult
    }

    public func savePreferredLanguage(_ entity: LocalizationEntity, for userId: UUID) async throws {
        savePreferredLanguageCalled = true
    }

    public func fetchLocalizationBundle() -> Bundle {
        fetchLocalizationBundleResult
    }

    public func fetchAvailableLocalizations() async throws -> [LocalizationEntity] {
        fetchAvailableLocalizationsResult
    }
}

// MARK: - Test Fixtures
public enum LocalizationCoreTesting {
    public static func makeLocalizationEntity() -> LocalizationEntity {
        LocalizationEntity(languageCode: "ko", languageLabel: "한국어")
    }
}
