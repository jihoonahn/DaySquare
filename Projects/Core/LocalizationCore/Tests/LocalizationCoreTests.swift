import Foundation
import Testing
@testable import LocalizationCore
@testable import LocalizationCoreTesting
import LocalizationDomainInterface

struct LocalizationCoreTests {

    @Test("LocalizationUseCaseImpl loadPreferredLanguage 호출 시 repository에 전달")
    func useCaseLoadPreferredLanguageDelegatesToRepository() async throws {
        let mock = MockLocalizationRepository()
        mock.loadPreferredLanguageResult = LocalizationCoreTesting.makeLocalizationEntity()
        let useCase = LocalizationUseCaseImpl(repository: mock)
        let result = try await useCase.loadPreferredLanguage(userId: UUID())
        #expect(result?.languageCode == "ko")
    }

    @Test("LocalizationUseCaseImpl savePreferredLanguage 호출 시 repository에 전달")
    func useCaseSavePreferredLanguageDelegatesToRepository() async throws {
        let mock = MockLocalizationRepository()
        let useCase = LocalizationUseCaseImpl(repository: mock)
        mock.fetchAvailableLocalizationsResult = [LocalizationEntity(languageCode: "en", languageLabel: "English")]
        try await useCase.savePreferredLanguage(userId: UUID(), languageCode: "en")
        #expect(mock.savePreferredLanguageCalled == true)
    }

    @Test("LocalizationUseCaseImpl fetchLocalizationBundle 호출 시 repository에 전달")
    func useCaseFetchLocalizationBundleDelegatesToRepository() throws {
        let mock = MockLocalizationRepository()
        let useCase = LocalizationUseCaseImpl(repository: mock)
        let bundle = useCase.fetchLocalizationBundle()
        #expect(bundle == Bundle.main)
    }
}
