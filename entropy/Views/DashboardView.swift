import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @Query private var allFood: [FoodEntry]
    @Query private var allExercise: [ExerciseEntry]
    @Query(sort: \WeightEntry.date, order: .reverse) private var allWeight: [WeightEntry]
    @Query private var goals: [Goal]

    @State private var showingFoodSheet = false
    @State private var showingExerciseSheet = false

    private var settings: AppSettings? { settingsList.first }

    private var todayFood: [FoodEntry] {
        allFood.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date > $1.date }
    }
    private var todayExercise: [ExerciseEntry] {
        allExercise.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date > $1.date }
    }

    private var totalConsumed: Double { todayFood.reduce(0) { $0 + $1.calories } }
    private var totalBurned: Double { todayExercise.reduce(0) { $0 + $1.caloriesBurned } }
    private var netCalories: Double { totalConsumed - totalBurned }

    private var suggestedTarget: Double? {
        guard let goal = goals.first, let latestWeight = allWeight.first else { return nil }
        let maintenance = CalorieTargetCalculator.roughMaintenanceEstimate(currentWeightInGrams: latestWeight.weightInGrams)
        return CalorieTargetCalculator.suggestedDailyIntake(goal: goal, currentWeightInGrams: latestWeight.weightInGrams, maintenanceCalories: maintenance)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    summaryRow(label: "Consumed", value: totalConsumed)
                    summaryRow(label: "Burned", value: totalBurned)
                    summaryRow(label: "Net", value: netCalories)
                    if let target = suggestedTarget {
                        HStack {
                            Text("Suggested target")
                            Spacer()
                            Text("\(Int(target)) kcal")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Food") {
                    ForEach(todayFood) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.name)
                                if !entry.servingDescription.isEmpty {
                                    Text(entry.servingDescription).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(Int(entry.calories)) kcal")
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { modelContext.delete(todayFood[index]) }
                    }
                    Button {
                        showingFoodSheet = true
                    } label: {
                        Label("Log food", systemImage: "plus.circle")
                    }
                }

                Section("Exercise") {
                    ForEach(todayExercise) { entry in
                        HStack {
                            Text(entry.activityName)
                            Spacer()
                            Text("-\(Int(entry.caloriesBurned)) kcal")
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { modelContext.delete(todayExercise[index]) }
                    }
                    Button {
                        showingExerciseSheet = true
                    } label: {
                        Label("Log exercise", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingFoodSheet) {
                FoodEntryFormSheet()
            }
            .sheet(isPresented: $showingExerciseSheet) {
                ExerciseLogView()
            }
        }
    }

    private func summaryRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value)) kcal").foregroundStyle(.secondary)
        }
    }
}
