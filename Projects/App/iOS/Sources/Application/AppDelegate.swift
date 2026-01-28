import UIKit
import ActivityKit
import AlarmKit
import UserNotifications
import Dependency
import SupabaseCoreInterface
import AlarmsDomainInterface
import AlarmSchedulesCoreInterface
import UsersDomainInterface
import NotificationDomainInterface
import BaseFeature
import WidgetKit

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
        
        Task {
            let container = DIContainer.shared
            let notificationUseCase = container.resolve(NotificationUseCase.self)
            await notificationUseCase.clearFallbackNotifications()
        }
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleAlarmNotification(notification: notification)
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    // 사용자가 Notification을 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleAlarmNotification(notification: response.notification)
        completionHandler()
    }
    
    // 알람 Notification 처리
    private func handleAlarmNotification(notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        // source 확인 (schedule인 경우 별도 처리)
        if let source = userInfo["source"] as? String, source == "schedule" {
            handleScheduleNotification(notification: notification)
            return
        }
        
        // alarmId 추출 (String 또는 UUID 타입 모두 처리)
        let alarmId: UUID?
        if let alarmIdString = userInfo["alarmId"] as? String,
           let parsedUUID = UUID(uuidString: alarmIdString) {
            alarmId = parsedUUID
        } else if let alarmIdUUID = userInfo["alarmId"] as? UUID {
            alarmId = alarmIdUUID
        } else {
            return
        }
        
        guard let finalAlarmId = alarmId else {
            return
        }
        
        // executionId 추출 (String 또는 UUID 타입 모두 처리)
        let executionId: UUID?
        if let executionIdString = userInfo["executionId"] as? String,
           let parsedUUID = UUID(uuidString: executionIdString) {
            executionId = parsedUUID
        } else if let executionIdUUID = userInfo["executionId"] as? UUID {
            executionId = executionIdUUID
        } else {
            executionId = nil
        }
        
        Task {
            await GlobalEventBus.shared.publish(AlarmEvent.triggered(alarmId: finalAlarmId, executionId: executionId))
        }
    }
    
    // 스케줄 Notification 처리
    private func handleScheduleNotification(notification: UNNotification) {
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        Task {
            let container = DIContainer.shared
            let userUseCase = container.resolve(UsersUseCase.self)
            guard let user = try? await userUseCase.getCurrentUser() else { return }
            
            let notificationUseCase = container.resolve(NotificationUseCase.self)
            guard let preference = try? await notificationUseCase.loadPreference(userId: user.id),
                  preference.isEnabled else {
                await notificationUseCase.clearFallbackNotifications()
                return
            }
            
            let alarmsUseCase = container.resolve(AlarmsUseCase.self)
            guard let alarms = try? await alarmsUseCase.fetchAll(userId: user.id) else { return }
            await notificationUseCase.scheduleFallbackNotifications(for: alarms)
        }
    }
    
    // MARK: - OAuth URL Handling
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return true
    }
}
