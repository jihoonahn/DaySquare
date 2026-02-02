import Foundation
import UserNotifications
import NotificationCoreInterface
import SchedulesDomainInterface

public final class NotificationServiceImpl: NotificationService {

    private let userDefaults: UserDefaults
    private let isEnabledKey = "com.daysquare.notification.isEnabled"
    private let schedulePrefix = "schedule-"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func saveIsEnabled(_ isEnabled: Bool) async throws {
        userDefaults.set(isEnabled, forKey: isEnabledKey)
        userDefaults.synchronize()
    }

    public func loadIsEnabled() async throws -> Bool? {
        guard userDefaults.object(forKey: isEnabledKey) != nil else {
            return nil
        }
        return userDefaults.bool(forKey: isEnabledKey)
    }

    public func updatePermissions(enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        if enabled {
            _ = await requestAuthorization(center: center)
        }
    }
    
    // MARK: - Schedule Notifications
    public func scheduleNotifications(for schedules: [SchedulesEntity]) async {
        // Notification 설정이 활성화되어 있는지 확인
        if let isEnabled = try? await loadIsEnabled(), !isEnabled {
            let center = UNUserNotificationCenter.current()
            await clearScheduleNotificationsInternal(center: center)
            return
        }
        
        let center = UNUserNotificationCenter.current()
        await clearScheduleNotificationsInternal(center: center)
        
        let granted = await requestAuthorization(center: center)
        guard granted else {
            return
        }
        
        let calendar = Calendar.current
        
        for schedule in schedules {
            // 스케줄 날짜와 시작 시간 파싱
            guard let scheduleDate = parseScheduleDate(schedule.date, startTime: schedule.startTime, calendar: calendar) else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = schedule.title
            content.body = schedule.description.isEmpty ? "스케줄이 시작됩니다." : schedule.description
            content.sound = .default
            content.userInfo = [
                "scheduleId": schedule.id.uuidString,
                "source": "schedule"
            ]
            
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: scheduleDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let identifier = schedulePrefix + schedule.id.uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await center.add(request)
            } catch {
                // 스케줄 notification 등록 실패
            }
        }
    }
    
    public func clearScheduleNotifications() async {
        let center = UNUserNotificationCenter.current()
        await clearScheduleNotificationsInternal(center: center)
    }
    
    // MARK: - Helpers
    private func requestAuthorization(center: UNUserNotificationCenter) async -> Bool {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            return true
        }
        return await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func pendingRequests(center: UNUserNotificationCenter) async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
    
    private func clearScheduleNotificationsInternal(center: UNUserNotificationCenter) async {
        let requests = await pendingRequests(center: center)
        let identifiers = requests
            .filter { $0.identifier.hasPrefix(schedulePrefix) }
            .map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    private func parseScheduleDate(_ dateString: String, startTime: String, calendar: Calendar) -> Date? {
        // 날짜 파싱 (다양한 형식 지원)
        // "yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-ddT00:00:00" 등
        let normalizedDateString = dateString
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ").first ?? dateString
            .components(separatedBy: "T").first ?? dateString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = calendar.timeZone
        
        guard let date = dateFormatter.date(from: normalizedDateString) else {
            return nil
        }
        
        // 시작 시간 파싱 (HH:mm 또는 HH:mm:ss 형식)
        // "HH:mm" 또는 "HH:mm:ss" 또는 "HH:mm:ss.SSS" 형식 지원
        let normalizedTime = startTime
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ").last ?? startTime
        
        let timeComponents = normalizedTime.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count >= 2 else {
            return nil
        }
        
        let hour = timeComponents[0]
        let minute = timeComponents[1]
        
        // 시간 범위 검증
        guard hour >= 0 && hour < 24 && minute >= 0 && minute < 60 else {
            return nil
        }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        
        guard let finalDate = calendar.date(from: dateComponents) else {
            return nil
        }
        
        return finalDate
    }
}
