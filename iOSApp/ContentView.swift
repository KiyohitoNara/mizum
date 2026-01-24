import Charts
import Feature
import HealthKit
import HealthKitUI
import OSLog
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var requestAuth = false
    @StateObject private var drinkStore: DrinkStore

    private let healthStore: HKHealthStore

    private let logger = Logger(subsystem: "com.kiyohitonara.Mizum", category: "ContentView")

    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore

        _drinkStore = StateObject(wrappedValue: DrinkStore(healthStore: healthStore))
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
                            logger.info("Adding 100ml drink.")
                            
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
                            logger.info("Adding 250ml drink.")
                            
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
                            logger.info("Adding 500ml drink.")
                            
                            Task {
                                await drinkStore.addDrink(ml: 500)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
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
        .onAppear {
            requestAuth = true
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                logger.info("App became active.")

                drinkStore.startObserving()
            case .inactive, .background:
                logger.info("App became inactive or entered background.")

                drinkStore.stopObserving()
            @unknown default:
                break
            }
        }

    }
}

#Preview {
    ContentView(healthStore: HKHealthStore())
}
