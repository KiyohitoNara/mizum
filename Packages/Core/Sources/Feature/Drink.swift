import Foundation
import HealthKit

public struct Drink: Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public let amount: Measurement<UnitVolume>

    public init(id: UUID = UUID(), date: Date, amount: Measurement<UnitVolume>) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

extension Drink {
    public static let dietaryWaterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!

    public static let types: Set<HKSampleType> = [
        dietaryWaterType
    ]
}

extension Drink {
    public init?(sample: HKQuantitySample) {
        guard sample.quantityType == Drink.dietaryWaterType else {
            return nil
        }

        self.id = sample.uuid
        self.date = sample.startDate
        self.amount = Measurement(value: sample.quantity.doubleValue(for: .liter()), unit: .liters)
    }
}
