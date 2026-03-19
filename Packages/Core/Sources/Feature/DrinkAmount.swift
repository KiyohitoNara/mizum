public enum DrinkAmount: Double, CaseIterable {
    case small = 100
    case medium = 250
    case large = 500

    public var identifier: String {
        return "io.github.kiyohitonara.mizum.action.drink_\(self.rawValue)"
    }

    public var title: String {
        return "Drink \(Int(self.rawValue))ml"
    }
}
