import HealthKit
import Testing

@testable import Feature

struct DrinkTest {
    @Test
    func initializesFromSample() {
        let sample = HKQuantitySample(
            type: Drink.dietaryWaterType,
            quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: 500),
            start: Date(),
            end: Date()
        )

        let drink = Drink(sample: sample)

        #expect(drink != nil)
        #expect(drink?.id == sample.uuid)
        #expect(drink?.date == sample.startDate)
        #expect(drink?.amount.value == 0.5)
    }
}
