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
    public static let types: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .dietaryWater)!
    ]
}
