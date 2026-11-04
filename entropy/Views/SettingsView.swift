import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @Query private var foodEntries: [FoodEntry]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var weightEntries: [WeightEntry]

    @State private var exportURL: URL?
    @State private var showingShareSheet = false

    private var settings: AppSettings? { settingsList.first }

    var body: some View {
        NavigationStack {
            Form {
                if let settings {
                    Section("Units") {
                        Picker("Units", selection: Binding(
                            get: { settings.unitPreference },
                            set: { settings.unitPreference = $0 }
                        )) {
                            Text("Imperial (lb, oz)").tag(UnitPreference.imperial)
                            Text("Metric (kg, g)").tag(UnitPreference.metric)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Reminders") {
                        Toggle("Meal reminder", isOn: Binding(
                            get: { settings.mealReminderEnabled },
                            set: { newValue in
                                settings.mealReminderEnabled = newValue
                                Task {
                                    await NotificationScheduler.requestAuthorizationIfNeeded()
                                    NotificationScheduler.syncReminders(from: settings)
                                }
                            }
                        ))
                        if settings.mealReminderEnabled {
                            DatePicker("Meal reminder time", selection: Binding(
                                get: { settings.mealReminderTime },
                                set: { newValue in
                                    settings.mealReminderTime = newValue
                                    NotificationScheduler.syncReminders(from: settings)
                                }
                            ), displayedComponents: .hourAndMinute)
                        }

                        Toggle("Weigh-in reminder", isOn: Binding(
                            get: { settings.weightReminderEnabled },
                            set: { newValue in
                                settings.weightReminderEnabled = newValue
                                Task {
                                    await NotificationScheduler.requestAuthorizationIfNeeded()
                                    NotificationScheduler.syncReminders(from: settings)
                                }
                            }
                        ))
                        if settings.weightReminderEnabled {
                            DatePicker("Weigh-in reminder time", selection: Binding(
                                get: { settings.weightReminderTime },
                                set: { newValue in
                                    settings.weightReminderTime = newValue
                                    NotificationScheduler.syncReminders(from: settings)
                                }
                            ), displayedComponents: .hourAndMinute)
                        }
                    }
                }

                Section("Export") {
                    Button("Export as CSV") { export(format: .csv) }
                    Button("Export as JSON") { export(format: .json) }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingShareSheet) {
                if let exportURL {
                    ShareSheet(activityItems: [exportURL])
                }
            }
        }
    }

    private func export(format: ExportFormat) {
        guard let url = ExportService.export(foodEntries: foodEntries, exerciseEntries: exerciseEntries, weightEntries: weightEntries, format: format) else { return }
        exportURL = url
        showingShareSheet = true
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
