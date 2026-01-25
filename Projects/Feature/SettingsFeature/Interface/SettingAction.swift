import Rex
import LocalizationDomainInterface

public enum SettingAction: ActionType {
    case fetchUserInformation
    case setUserInformation(name: String, email: String)
    case nameTextDidChanged(String)
    case emailTextDidChanged(String)
    case saveProfile(String)
    case deleteUserAccount
    case confirmDeleteUserAccount
    case showToast(String)
    case toastStatus(Bool)
    case logout
    case showDeleteAlert(Bool)

    // Language Settings
    case loadLanguage
    case setAvailableLanguages([LocalizationEntity])
    case setLanguage(String)
    case saveLanguage(String)

    // Notification Settings
    case loadNotificationSetting
    case setNotificationSetting(Bool)
    case saveNotificationSetting(Bool)
}
