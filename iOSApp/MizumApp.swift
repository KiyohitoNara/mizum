import HealthKit
import SwiftUI

@main
struct MizumApp: App {
    private let healthStore = HKHealthStore()

    var body: some Scene {
        WindowGroup {
            ContentView(healthStore: healthStore)
        }
    }
}
