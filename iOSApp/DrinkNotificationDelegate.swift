import Feature
import OSLog
import SwiftUI
import UserNotifications

@MainActor
class DrinkNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let drinkStore: DrinkStore

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DrinkReminder")

    init(drinkStore: DrinkStore) {
        self.drinkStore = drinkStore
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        logger.info("Received drink reminder notification response: \(response.actionIdentifier)")

        if let amount = DrinkAmount.allCases.first(where: { $0.identifier == response.actionIdentifier }) {
            logger.info("Handling drink reminder action for amount: \(amount.rawValue)ml")

            await drinkStore.addDrink(ml: amount.rawValue)
        }
    }
}
