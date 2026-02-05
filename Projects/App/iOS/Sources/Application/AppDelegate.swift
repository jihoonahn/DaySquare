import UIKit
import UserNotifications
import Dependency
import SupabaseCoreInterface

final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Notification Center Delegate 설정
        UNUserNotificationCenter.current().delegate = self
        
        // Notification Category 등록
        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleNotification(notification: notification)
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    // 사용자가 Notification을 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotification(notification: response.notification)
        completionHandler()
    }
    
    // Notification 처리 (Schedules 전용 - AlarmKit은 Notification 사용 안 함)
    private func handleNotification(notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let source = userInfo["source"] as? String, source == "schedule" else {
            return
        }
        // 스케줄 notification은 단순 알림이므로 추가 처리 없음
    }
 
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        switch extensionPointIdentifier {
        case .keyboard:
            return false
        default:
            return true
        }
    }
    
    
    // MARK: - OAuth URL Handling (Google 등 리다이렉트 콜백)
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        let supabaseService = DIContainer.shared.resolve(SupabaseService.self) 
        supabaseService.client.auth.handle(url)
        return true
    }
}
