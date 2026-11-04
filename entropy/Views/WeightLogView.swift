import SwiftUI
import SwiftData

struct WeightLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]
    @Query private var goals: [Goal]

    @State private var showingAddEntry = false
    @State private var showingGoalSheet = false
    @State private var newWeightDisplay = ""
    @State private var newDate = Date.now

    private var unitPreference: UnitPreference { settingsList.first?.unitPreference ?? .imperial }
    private var goal: Goal? { goals.first }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    WeightTrendChartView(entries: entries, unitPreference: unitPreference)
                        .listRowInsets(EdgeInsets())
                }

                Section("Goal") {
                    if let goal {
                        HStack {
                            Text("Target")
                            Spacer()
                            Text("\(String(format: "%.1f", UnitConversion.displayWeight(grams: goal.targetWeightInGrams, preference: unitPreference))) \(UnitConversion.weightUnitLabel(unitPreference)) by \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button(goal == nil ? "Set a goal" : "Edit goal") {
                        showingGoalSheet = true
                    }
                }

                Section("Entries") {
                    ForEach(entries) { entry in
                        HStack {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text("\(String(format: "%.1f", UnitConversion.displayWeight(grams: entry.weightInGrams, preference: unitPreference))) \(UnitConversion.weightUnitLabel(unitPreference))")
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { modelContext.delete(entries[index]) }
                    }
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Log weight", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Weight")
            .sheet(isPresented: $showingGoalSheet) {
                GoalSettingsView(existingGoal: goal)
            }
            .sheet(isPresented: $showingAddEntry) {
                addEntrySheet
            }
        }
    }

    private var addEntrySheet: some View {
        NavigationStack {
            Form {
                TextField("Weight (\(UnitConversion.weightUnitLabel(unitPreference)))", text: $newWeightDisplay)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $newDate, displayedComponents: .date)
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddEntry = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveNewEntry() }
                        .disabled(Double(newWeightDisplay) == nil)
                }
            }
        }
    }

    private func saveNewEntry() {
        guard let value = Double(newWeightDisplay) else { return }
        let grams = UnitConversion.gramsFromDisplayWeight(value, preference: unitPreference)
        modelContext.insert(WeightEntry(date: newDate, weightInGrams: grams))
        newWeightDisplay = ""
        showingAddEntry = false
    }
}
