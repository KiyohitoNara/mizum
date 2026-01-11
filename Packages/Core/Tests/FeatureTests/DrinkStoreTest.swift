import HealthKit
import Testing

@testable import Feature

@MainActor
struct DrinkStoreTest {
    @Test
    func calculatesTotalsCorrectly() async {
        let store = DrinkStore(healthStore: HKHealthStore())
        store.samples = [
            Drink(date: Date(), amount: Measurement(value: 250, unit: .milliliters)),
            Drink(date: Date(), amount: Measurement(value: 500, unit: .milliliters)),
            Drink(date: Date(), amount: Measurement(value: 750, unit: .milliliters)),
        ]

        #expect(store.totals.count == 4)
        #expect(store.totals[0].amount.value == 0)  // Initial total
        #expect(store.totals[1].amount.value == 250)
        #expect(store.totals[2].amount.value == 750)
        #expect(store.totals[3].amount.value == 1500)
    }
}
