import Charts
import Feature
import SwiftUI

struct DrinkChart: View {
    let goal: Double
    let drinks: [Drink]

    private var startOfDay: Date { Calendar.current.startOfDay(for: Date()) }
    private var endOfDay: Date { Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? startOfDay }

    private var totalAmount: Double {
        drinks.last?.amount.converted(to: .milliliters).value ?? 0
    }

    private var totalValue: String {
        if totalAmount >= 1000 {
            return String(format: "%.1f", totalAmount / 1000)
        } else {
            return "\(Int(totalAmount))"
        }
    }

    private var totalUnit: String {
        totalAmount >= 1000 ? "L" : "ml"
    }

    private var maxY: Double {
        let lastAmount = drinks.last?.amount.converted(to: .milliliters).value ?? 0

        return max(goal, lastAmount) * 1.1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                (Text(totalValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    + Text(" \(totalUnit)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary))
                Text("Today's water intake")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            Chart {
                RuleMark(y: .value("Goal", goal))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(.red)

                ForEach(drinks) { drink in
                    AreaMark(
                        x: .value("Time", drink.date),
                        y: .value("Total", drink.amount.converted(to: .milliliters).value)
                    )
                    .interpolationMethod(.stepStart)
                    .foregroundStyle(Color.blue.opacity(0.1).gradient)

                    LineMark(
                        x: .value("Time", drink.date),
                        y: .value("Total", drink.amount.converted(to: .milliliters).value)
                    )
                    .interpolationMethod(.stepStart)
                    .foregroundStyle(.blue)
                }
            }
            .chartXScale(domain: startOfDay...endOfDay)
            .chartYScale(domain: 0...maxY)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.secondary.opacity(0.2))
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 500)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let ml = value.as(Double.self) {
                        AxisValueLabel("\(Int(ml))ml")
                    }
                }
            }
        }
    }
}

#Preview {
    DrinkChart(
        goal: 2000,
        drinks: [
            Drink(date: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, amount: Measurement(value: 100, unit: .milliliters)),
            Drink(date: Calendar.current.date(byAdding: .hour, value: 0, to: Date())!, amount: Measurement(value: 200, unit: .milliliters)),
            Drink(date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, amount: Measurement(value: 300, unit: .milliliters)),
        ]
    )
}
