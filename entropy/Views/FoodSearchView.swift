import SwiftUI
import SwiftData

struct FoodSearchView: View {
    var onSaved: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var query = ""
    @State private var results: [USDAFoodResult] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedResult: USDAFoodResult?
    @State private var servingMultiplier: Double = 1.0
    @State private var overrideCalories: String = ""
    @State private var useOverride = false

    private let client = USDAFoodClient()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Search food (e.g. chow mein)", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await runSearch() } }
                Button("Search") { Task { await runSearch() } }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)

            if isSearching {
                ProgressView().padding()
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote).padding(.horizontal)
            }

            List(results) { result in
                Button {
                    selectedResult = result
                    servingMultiplier = 1.0
                    useOverride = false
                    overrideCalories = ""
                } label: {
                    VStack(alignment: .leading) {
                        Text(result.description)
                        Text("\(Int(result.caloriesPerServing)) kcal / \(result.servingDescription)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)

            if let selectedResult {
                saveForm(for: selectedResult)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private func saveForm(for result: USDAFoodResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text("Serving multiplier").font(.caption).foregroundStyle(.secondary)
            Stepper(value: $servingMultiplier, in: 0.25...10, step: 0.25) {
                Text(String(format: "%.2fx serving (%@)", servingMultiplier, result.servingDescription))
            }

            Toggle("Override calorie count", isOn: $useOverride)
            if useOverride {
                TextField("Calories", text: $overrideCalories)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            let computedCalories = result.caloriesPerServing * servingMultiplier
            Text("Will log: \(Int(finalCalories(computed: computedCalories))) kcal")
                .font(.subheadline.bold())

            Button("Save") {
                save(result: result, computedCalories: computedCalories)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }

    private func finalCalories(computed: Double) -> Double {
        if useOverride, let value = Double(overrideCalories) {
            return value
        }
        return computed
    }

    private func save(result: USDAFoodResult, computedCalories: Double) {
        let calories = finalCalories(computed: computedCalories)
        let source: FoodEntrySource = useOverride ? .manualOverride : .database
        let entry = FoodEntry(
            name: result.description,
            calories: calories,
            source: source,
            servingDescription: String(format: "%.2fx %@", servingMultiplier, result.servingDescription)
        )
        modelContext.insert(entry)
        onSaved()
    }

    private func runSearch() async {
        errorMessage = nil
        isSearching = true
        defer { isSearching = false }
        do {
            results = try await client.search(query: query)
        } catch USDAFoodClientError.missingAPIKey {
            errorMessage = "No USDA API key configured. Add one to entropy/APIKeys.plist."
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }
}
