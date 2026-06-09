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

    @Test
    func producesSingleZeroTotalWhenEmpty() async {
        let store = DrinkStore(healthStore: HKHealthStore())
        store.samples = []

        #expect(store.totals.count == 1)
        #expect(store.totals[0].amount.value == 0)
    }

    @Test
    func producesInitialAndCumulativeForSingleSample() async {
        let store = DrinkStore(healthStore: HKHealthStore())
        let date = Date()
        store.samples = [
            Drink(date: date, amount: Measurement(value: 250, unit: .milliliters))
        ]

        #expect(store.totals.count == 2)
        #expect(store.totals[0].amount.value == 0)
        #expect(store.totals[1].amount.value == 250)
        #expect(store.totals[1].date == date)
    }

    @Test
    func anchorsInitialTotalAtStartOfDay() async {
        let store = DrinkStore(healthStore: HKHealthStore())
        store.samples = [
            Drink(date: Date(), amount: Measurement(value: 100, unit: .milliliters))
        ]

        #expect(store.totals[0].date == Calendar.current.startOfDay(for: Date()))
    }
}
