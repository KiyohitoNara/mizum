import Feature
import HealthKit
import SwiftUI

@main
struct MizumApp: App {
    @State private var drinkStore: DrinkStore
    @State private var drinkReminder: DrinkReminder

    private let notificationDelegate: DrinkNotificationDelegate

    init() {
        _drinkStore = State(wrappedValue: DrinkStore(healthStore: HKHealthStore()))
        _drinkReminder = State(wrappedValue: DrinkReminder())

        notificationDelegate = DrinkNotificationDelegate(drinkStore: _drinkStore.wrappedValue)
        drinkReminder.setupNotificationDelegate(delegate: notificationDelegate)
        drinkReminder.setupNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(drinkStore)
                .environment(drinkReminder)
        }
    }
}
