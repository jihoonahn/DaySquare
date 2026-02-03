import Testing
import Rex
@testable import SettingsFeature
import SettingsFeatureInterface
import LocalizationDomainInterface
import SettingsFeatureTesting

struct SettingsFeatureTests {

    @Test("nameTextDidChanged 시 name 업데이트")
    func nameTextDidChanged() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .nameTextDidChanged("New Name"))
        #expect(state.name == "New Name")
    }

    @Test("emailTextDidChanged 시 email 업데이트")
    func emailTextDidChanged() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .emailTextDidChanged("new@email.com"))
        #expect(state.email == "new@email.com")
    }

    @Test("setNotificationSetting 시 notificationEnabled 업데이트")
    func setNotificationSetting() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .setNotificationSetting(false))
        #expect(state.notificationEnabled == false)
        _ = reducer.reduce(state: &state, action: .setNotificationSetting(true))
        #expect(state.notificationEnabled == true)
    }

    @Test("setAvailableLanguages 시 languages 업데이트")
    func setAvailableLanguages() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        let langs = [
            LocalizationEntity(languageCode: "ko", languageLabel: "한국어"),
            LocalizationEntity(languageCode: "en", languageLabel: "English")
        ]
        _ = reducer.reduce(state: &state, action: .setAvailableLanguages(langs))
        #expect(state.languages.count == 2)
        #expect(state.languages[0].languageCode == "ko")
    }

    @Test("setLanguage 시 languageCode 업데이트")
    func setLanguage() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .setLanguage("en"))
        #expect(state.languageCode == "en")
    }

    @Test("showDeleteAlert 시 showDeleteAlert 업데이트")
    func showDeleteAlert() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .showDeleteAlert(true))
        #expect(state.showDeleteAlert == true)
    }

    @Test("showToast / toastStatus 시 toastMessage, toastIsPresented 업데이트")
    func showToastAndStatus() throws {
        let reducer = SettingReducer(
            usersUseCase: MockUsersUseCaseForSettings(),
            localizationUseCase: MockLocalizationUseCaseForSettings(),
            notificationUseCase: MockNotificationUseCaseForSettings()
        )
        var state = SettingState()
        _ = reducer.reduce(state: &state, action: .showToast("저장됨"))
        #expect(state.toastMessage == "저장됨")
        _ = reducer.reduce(state: &state, action: .toastStatus(true))
        #expect(state.toastIsPresented == true)
    }
}
