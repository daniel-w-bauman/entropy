import SwiftUI
import Charts

enum ChartGranularity: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    var id: String { rawValue }
}

struct WeightTrendChartView: View {
    let entries: [WeightEntry]
    let unitPreference: UnitPreference
    @State private var granularity: ChartGranularity = .daily

    private var points: [(Date, Double)] {
        let sorted = entries.sorted { $0.date < $1.date }
        let grouped: [Date: [WeightEntry]]
        switch granularity {
        case .daily:
            grouped = Dictionary(grouping: sorted) { Calendar.current.startOfDay(for: $0.date) }
        case .weekly:
            grouped = Dictionary(grouping: sorted) { entry in
                Calendar.current.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
            }
        case .monthly:
            grouped = Dictionary(grouping: sorted) { entry in
                Calendar.current.dateInterval(of: .month, for: entry.date)?.start ?? entry.date
            }
        }
        return grouped.map { key, values in
            let average = values.reduce(0) { $0 + $1.weightInGrams } / Double(values.count)
            return (key, UnitConversion.displayWeight(grams: average, preference: unitPreference))
        }
        .sorted { $0.0 < $1.0 }
    }

    var body: some View {
        VStack {
            Picker("Granularity", selection: $granularity) {
                ForEach(ChartGranularity.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if points.isEmpty {
                Text("Log a weight entry to see your trend.")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                Chart(points, id: \.0) { point in
                    LineMark(x: .value("Date", point.0), y: .value("Weight", point.1))
                    PointMark(x: .value("Date", point.0), y: .value("Weight", point.1))
                }
                .frame(height: 220)
                .padding(.horizontal)
            }
        }
    }
}
