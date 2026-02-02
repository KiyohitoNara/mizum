import Feature
import Foundation
import OSLog
import Observation
import UserNotifications

@MainActor
@Observable
final class DrinkReminder {
    public private(set) var authorized: Bool = false

    private let notificationCenter = UNUserNotificationCenter.current()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DrinkReminder")

    public func requestAuthorization() async {
        logger.info("Checking notification authorization status.")

        let settings = await notificationCenter.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            logger.info("Requesting notification authorization.")

            do {
                try await notificationCenter.requestAuthorization(options: [.alert, .sound])

                logger.info("Successfully requested notification authorization.")
            } catch {
                logger.error("Failed to request notification authorization: \(error.localizedDescription)")
            }
        }

        authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    public func setupNotificationDelegate(delegate: UNUserNotificationCenterDelegate) {
        logger.info("Setting up notification delegate.")

        notificationCenter.delegate = delegate
    }

    public func setupNotificationCategories() {
        logger.info("Setting up notification categories and actions.")

        let actions = DrinkAmount.allCases.map { amount in
            UNNotificationAction(
                identifier: amount.identifier,
                title: amount.title,
            )
        }

        let category = UNNotificationCategory(identifier: "io.github.kiyohitonara.mizum.reminder", actions: actions, intentIdentifiers: [])
        notificationCenter.setNotificationCategories([category])
    }

    public func scheduleReminders(startDate: Date, endDate: Date) async {
        logger.info("Scheduling reminders.")

        // Check authorization
        guard authorized else {
            logger.warning("Skipping scheduling reminders because authorization is not granted.")

            return
        }

        // Remove old reminders
        removeAllScheduledReminders()

        // Schedule new reminders
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startDate)
        let startMinute = calendar.component(.minute, from: startDate)
        let endHour = calendar.component(.hour, from: endDate)
        for hour in startHour...endHour {
            logger.info("Scheduling reminder for hour \(hour).")

            let identifier = Bundle.main.bundleIdentifier! + ".reminder.\(hour)"

            let content = UNMutableNotificationContent()
            content.title = "Time to Drink"
            content.body = "A glass of water now is a good choice."
            content.categoryIdentifier = "io.github.kiyohitonara.mizum.reminder"
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = startMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await notificationCenter.add(request)

                logger.info("Successfully scheduled drink reminder for hour \(hour).")
            } catch {
                logger.error("Failed to schedule drink reminder for hour \(hour): \(error.localizedDescription)")
            }
        }
    }

    public func removeAllScheduledReminders() {
        logger.info("Removing all scheduled drink reminders.")

        notificationCenter.removeAllPendingNotificationRequests()
    }
}
