import Feature
import HealthKit
import SwiftUI

@main
struct MizumApp: App {
    @State private var drinkStore = DrinkStore(healthStore: HKHealthStore())
    @State private var drinkReminder = DrinkReminder()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(drinkStore)
                .environment(drinkReminder)
        }
    }
}
