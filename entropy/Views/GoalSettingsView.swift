import SwiftUI
import SwiftData

struct GoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @Query(sort: \WeightEntry.date, order: .reverse) private var allWeight: [WeightEntry]

    let existingGoal: Goal?

    @State private var targetWeightDisplay: String = ""
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now

    private var unitPreference: UnitPreference { settingsList.first?.unitPreference ?? .imperial }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Target weight (\(UnitConversion.weightUnitLabel(unitPreference)))", text: $targetWeightDisplay)
                    .keyboardType(.decimalPad)
                DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
            }
            .navigationTitle("Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Double(targetWeightDisplay) == nil)
                }
            }
            .onAppear {
                if let goal = existingGoal {
                    targetWeightDisplay = String(format: "%.1f", UnitConversion.displayWeight(grams: goal.targetWeightInGrams, preference: unitPreference))
                    targetDate = goal.targetDate
                }
            }
        }
    }

    private func save() {
        guard let displayValue = Double(targetWeightDisplay) else { return }
        let targetGrams = UnitConversion.gramsFromDisplayWeight(displayValue, preference: unitPreference)
        let startWeight = allWeight.first?.weightInGrams ?? targetGrams

        if let goal = existingGoal {
            goal.targetWeightInGrams = targetGrams
            goal.targetDate = targetDate
        } else {
            let goal = Goal(targetWeightInGrams: targetGrams, targetDate: targetDate, startWeightInGrams: startWeight)
            modelContext.insert(goal)
        }
        dismiss()
    }
}
