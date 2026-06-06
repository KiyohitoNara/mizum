import Charts
import Feature
import HealthKit
import HealthKitUI
import OSLog
import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(DrinkStore.self) private var drinkStore
    @Environment(DrinkReminder.self) private var drinkReminder

    @State private var requestAuth = false

    // Daily goal
    @AppStorage("dailyGoal") private var dailyGoal = 2000

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

    private let logger = Logger(subsystem: "com.kiyohitonara.Mizum", category: "ContentView")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DrinkChart(goal: Double(dailyGoal), drinks: drinkStore.totals)
                    .frame(height: 200)
                    .padding()

                Form {
                    Section("Water") {
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

                    Section("Reminders") {
                        Stepper("Goal: \(dailyGoal)ml", value: $dailyGoal, in: 500...5000, step: 100)

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
            }
            .navigationTitle("Mizum")
        }
        .healthDataAccessRequest(store: drinkStore.healthStore, shareTypes: Drink.types, readTypes: Drink.types, trigger: requestAuth) { result in
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
            UIDatePicker.appearance().minuteInterval = 5

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
    ContentView()
        .environment(DrinkStore(healthStore: HKHealthStore()))
        .environment(DrinkReminder())
}
