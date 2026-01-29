import Charts
import Feature
import HealthKit
import HealthKitUI
import OSLog
import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var requestAuth = false
    @State private var drinkStore: DrinkStore
    @State private var drinkReminder = DrinkReminder()

    // Reminder enabled
    @AppStorage("remindersEnabled") private var remindersEnabled = false

    // Reminder start time
    @AppStorage("reminderStartTime") private var reminderStartTime = {
        let calendar = Calendar.current
        let now = Date()

        return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
    }()

    // Reminder end time
    @AppStorage("reminderEndTime") private var reminderEndTime = {
        let calendar = Calendar.current
        let now = Date()

        return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
    }()

    private let healthStore: HKHealthStore

    private let logger = Logger(subsystem: "com.kiyohitonara.Mizum", category: "ContentView")

    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore

        drinkStore = DrinkStore(healthStore: healthStore)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DrinkChart(goal: 2000, drinks: drinkStore.totals)
                        .frame(height: 200)

                    HStack {
                        Label("100ml", systemImage: "cup.and.saucer.fill")
                        Spacer()
                        Button("", systemImage: "plus") {
                            Task {
                                await drinkStore.addDrink(ml: 100)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)

                    HStack {
                        Label("250ml", systemImage: "mug.fill")
                        Spacer()
                        Button("", systemImage: "plus") {
                            Task {
                                await drinkStore.addDrink(ml: 250)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)

                    HStack {
                        Label("500ml", systemImage: "waterbottle.fill")
                        Spacer()
                        Button("", systemImage: "plus") {
                            Task {
                                await drinkStore.addDrink(ml: 500)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }

                Section {
                    Toggle("Reminder", isOn: $remindersEnabled)
                        .disabled(!drinkReminder.authorized)
                        .onChange(of: remindersEnabled) {
                            updateScheduledReminders()
                        }

                    DatePicker("Start", selection: $reminderStartTime, displayedComponents: .hourAndMinute)
                        .disabled(!remindersEnabled || !drinkReminder.authorized)
                        .onChange(of: reminderStartTime) {
                            updateScheduledReminders()
                        }

                    DatePicker("End", selection: $reminderEndTime, displayedComponents: .hourAndMinute)
                        .disabled(!remindersEnabled || !drinkReminder.authorized)
                        .onChange(of: reminderEndTime) {
                            updateScheduledReminders()
                        }
                }
            }
            .navigationTitle("Mizum")
        }
        .healthDataAccessRequest(store: healthStore, shareTypes: Drink.types, readTypes: Drink.types, trigger: requestAuth) { result in
            switch result {
            case .success:
                logger.info("Authorize HealthKit data access succeeded.")

                Task {
                    await drinkStore.startObserving()
                }
            case .failure:
                logger.error("Authorize HealthKit data access failed.")
            }
        }
        .task {
            await drinkReminder.requestAuthorization()
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 10

            requestAuth = true
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                drinkStore.startObserving()
            case .inactive, .background:
                drinkStore.stopObserving()
            @unknown default:
                break
            }
        }
    }

    private func updateScheduledReminders() {
        logger.info("Updating scheduled reminders.")

        if remindersEnabled {
            Task {
                await drinkReminder.scheduleReminders(startDate: reminderStartTime, endDate: reminderEndTime)
            }
        } else {
            drinkReminder.removeAllScheduledReminders()
        }
    }
}

#Preview {
    ContentView(healthStore: HKHealthStore())
}
