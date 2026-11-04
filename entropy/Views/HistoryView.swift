import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.date, order: .reverse) private var foodEntries: [FoodEntry]
    @Query(sort: \ExerciseEntry.date, order: .reverse) private var exerciseEntries: [ExerciseEntry]

    private struct DaySummary: Identifiable {
        let id: Date
        let date: Date
        let consumed: Double
        let burned: Double
    }

    private var days: [DaySummary] {
        let calendar = Calendar.current
        let foodByDay = Dictionary(grouping: foodEntries) { calendar.startOfDay(for: $0.date) }
        let exerciseByDay = Dictionary(grouping: exerciseEntries) { calendar.startOfDay(for: $0.date) }
        let allDays = Set(foodByDay.keys).union(exerciseByDay.keys)

        return allDays.map { day in
            let consumed = foodByDay[day]?.reduce(0) { $0 + $1.calories } ?? 0
            let burned = exerciseByDay[day]?.reduce(0) { $0 + $1.caloriesBurned } ?? 0
            return DaySummary(id: day, date: day, consumed: consumed, burned: burned)
        }
        .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List(days) { day in
                NavigationLink {
                    DayDetailView(date: day.date, foodEntries: foodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: day.date) }, exerciseEntries: exerciseEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: day.date) })
                } label: {
                    HStack {
                        Text(day.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("Net \(Int(day.consumed - day.burned)) kcal")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("History")
            .overlay {
                if days.isEmpty {
                    Text("No entries yet.").foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct DayDetailView: View {
    let date: Date
    let foodEntries: [FoodEntry]
    let exerciseEntries: [ExerciseEntry]

    var body: some View {
        List {
            Section("Food") {
                ForEach(foodEntries) { entry in
                    HStack {
                        Text(entry.name)
                        Spacer()
                        Text("\(Int(entry.calories)) kcal")
                    }
                }
            }
            Section("Exercise") {
                ForEach(exerciseEntries) { entry in
                    HStack {
                        Text(entry.activityName)
                        Spacer()
                        Text("-\(Int(entry.caloriesBurned)) kcal")
                    }
                }
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}
