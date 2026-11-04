import Foundation
import UserNotifications

enum NotificationScheduler {
    static let mealReminderID = "meal-reminder"
    static let weightReminderID = "weight-reminder"

    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    static func syncReminders(from settings: AppSettings) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [mealReminderID, weightReminderID])

        if settings.mealReminderEnabled {
            schedule(id: mealReminderID, time: settings.mealReminderTime, title: "Log your meals", body: "Don't forget to log what you've eaten today.", on: center)
        }
        if settings.weightReminderEnabled {
            schedule(id: weightReminderID, time: settings.weightReminderTime, title: "Weigh-in reminder", body: "Time to log today's weight.", on: center)
        }
    }

    private static func schedule(id: String, time: Date, title: String, body: String, on center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
}
