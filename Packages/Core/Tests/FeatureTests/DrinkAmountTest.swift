import Testing

@testable import Feature

struct DrinkAmountTest {
    @Test
    func hasExpectedRawValues() {
        #expect(DrinkAmount.small.rawValue == 100)
        #expect(DrinkAmount.medium.rawValue == 250)
        #expect(DrinkAmount.large.rawValue == 500)
    }

    @Test
    func buildsIdentifierFromRawValue() {
        #expect(DrinkAmount.small.identifier == "io.github.kiyohitonara.mizum.action.drink_100.0")
        #expect(DrinkAmount.medium.identifier == "io.github.kiyohitonara.mizum.action.drink_250.0")
        #expect(DrinkAmount.large.identifier == "io.github.kiyohitonara.mizum.action.drink_500.0")
    }

    @Test
    func listsAllCases() {
        #expect(DrinkAmount.allCases == [.small, .medium, .large])
    }
}
