import Algorithms
import Foundation
import HealthKit
import OSLog

@MainActor
public final class DrinkStore: ObservableObject {
    // Published drink samples
    @Published public internal(set) var samples: [Drink] = [] {
        didSet {
            // Calculate cumulative totals
            let sums = samples.reductions(0.0) { result, drink in
                result + drink.amount.converted(to: .milliliters).value
            }

            // Build totals array
            totals = []

            // Add initial total at start of day
            if let total = sums.first {
                let date = Calendar.current.startOfDay(for: Date())
                totals.append(Drink(date: date, amount: Measurement(value: total, unit: .milliliters)))
            }

            // Add totals for each drink
            for (idx, drink) in samples.enumerated() {
                totals.append(Drink(date: drink.date, amount: Measurement(value: sums[idx + 1], unit: .milliliters)))
            }
        }
    }

    // Published cumulative totals
    @Published public internal(set) var totals: [Drink] = []

    private let healthStore: HKHealthStore
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DrinkStore")

    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func addDrink(ml: Double) async {
        logger.info("Adding a new drink of \(ml) ml to HealthKit.")

        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: ml)
        let now = Date()
        let sample = HKQuantitySample(type: Drink.dietaryWaterType, quantity: quantity, start: now, end: now)

        do {
            try await healthStore.save(sample)
            
            logger.info("Successfully saved drink sample to HealthKit.")
        } catch {
            logger.error("Failed to save drink sample: \(error.localizedDescription)")
        }
    }

    public func fetchDrinks() async {
        logger.info("Fetching today's drinks from HealthKit.")

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let description = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: Drink.dietaryWaterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [description]) {
            [weak self] _, samples, error in
            if let error {
                self?.logger.error("Failed to fetch drink samples: \(error.localizedDescription)")
            } else {
                self?.logger.info("Received \(samples?.count ?? 0) drink samples from HealthKit.")
            }

            let results = (samples as? [HKQuantitySample])?.compactMap { Drink(sample: $0) }
            Task { @MainActor in
                self?.samples = results ?? []
            }
        }
        healthStore.execute(query)
    }
}
