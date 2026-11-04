import SwiftUI
import SwiftData

struct ExerciseLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var activityName = ""
    @State private var caloriesBurned = ""
    @State private var date = Date.now

    var body: some View {
        NavigationStack {
            Form {
                TextField("Activity (e.g. running)", text: $activityName)
                TextField("Calories burned", text: $caloriesBurned)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date)
            }
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(activityName.trimmingCharacters(in: .whitespaces).isEmpty || Double(caloriesBurned) == nil)
                }
            }
        }
    }

    private func save() {
        guard let calories = Double(caloriesBurned) else { return }
        let entry = ExerciseEntry(activityName: activityName, date: date, caloriesBurned: calories)
        modelContext.insert(entry)
        dismiss()
    }
}
