import Algorithms
import Foundation
import HealthKit
import OSLog
import Observation

@MainActor
@Observable
public final class DrinkStore {
    // Published drink samples
    public internal(set) var samples: [Drink] = [] {
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
    public internal(set) var totals: [Drink] = []

    private let healthStore: HKHealthStore
    private var observerQuery: HKObserverQuery?
    private var anchor: HKQueryAnchor?

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DrinkStore")

    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func startObserving() {
        logger.info("Starting observation of drink samples from HealthKit.")

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: nil, options: .strictStartDate)

        let query = HKObserverQuery(sampleType: Drink.dietaryWaterType, predicate: predicate) {
            [weak self] _, completionHandler, error in
            defer {
                completionHandler()
            }

            if let error {
                self?.logger.error("Failed to observe drink samples: \(error.localizedDescription)")

                return
            } else {
                self?.logger.info("Observed a change in drink samples from HealthKit.")
            }

            Task { @MainActor in
                self?.fetchDrinks()
            }
        }

        observerQuery = query
        healthStore.execute(query)
    }

    public func stopObserving() {
        if let observerQuery {
            logger.info("Stopping observation of drink samples from HealthKit.")

            healthStore.stop(observerQuery)
        }

        observerQuery = nil
    }

    public func fetchDrinks() {
        logger.info("Fetching today's drinks from HealthKit.")

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKAnchoredObjectQuery(type: Drink.dietaryWaterType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) {
            [weak self] _, samples, _, newAnchor, error in
            if let error {
                self?.logger.error("Failed to fetch drink samples: \(error.localizedDescription)")

                return
            } else {
                self?.logger.info("Received \(samples?.count ?? 0) drink samples from HealthKit.")
            }

            let result = (samples as? [HKQuantitySample])?.compactMap { Drink(sample: $0) }
            Task { @MainActor in
                if let result {
                    self?.samples.append(contentsOf: result)
                    self?.samples.sort { $0.date < $1.date }
                }

                self?.anchor = newAnchor
            }
        }

        healthStore.execute(query)
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
}
