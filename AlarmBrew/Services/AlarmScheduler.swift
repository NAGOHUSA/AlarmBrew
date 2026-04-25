import Foundation
import UserNotifications

/// Manages scheduling and cancellation of local alarm notifications.
final class AlarmScheduler {
    static let shared = AlarmScheduler()
    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("AlarmBrew: notification permission error – \(error)")
            }
        }
    }

    // MARK: - Schedule

    func schedule(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "AlarmBrew ☕" : alarm.label
        content.body = "Wake up! Take a photo of your coffee maker to dismiss."
        content.sound = UNNotificationSound.default
        content.userInfo = ["alarmId": alarm.id.uuidString]

        var components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)

        if alarm.repeatDays.isEmpty {
            add(identifier: alarm.id.uuidString, content: content,
                dateComponents: components, repeats: false)
        } else {
            for weekday in alarm.repeatDays {
                components.weekday = weekday
                let identifier = "\(alarm.id.uuidString)_\(weekday)"
                add(identifier: identifier, content: content,
                    dateComponents: components, repeats: true)
            }
        }
    }

    // MARK: - Cancel

    func cancel(_ alarmId: UUID) {
        var ids = [alarmId.uuidString]
        (1...7).forEach { ids.append("\(alarmId.uuidString)_\($0)") }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Private

    private func add(
        identifier: String,
        content: UNNotificationContent,
        dateComponents: DateComponents,
        repeats: Bool
    ) {
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("AlarmBrew: failed to schedule – \(error)")
            }
        }
    }
}
