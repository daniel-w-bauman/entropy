import SwiftUI
import SwiftData

private struct IngredientRow: Identifiable {
    let id = UUID()
    var name: String = ""
    var calories: String = ""
    var weightGrams: String = ""
}

struct IngredientCalcView: View {
    var onSaved: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var dishName: String = ""
    @State private var ingredients: [IngredientRow] = [IngredientRow()]
    @State private var servingWeightGrams: String = ""
    @State private var useOverride = false
    @State private var overrideCalories: String = ""

    private var totalIngredientCalories: Double {
        ingredients.reduce(0) { $0 + (Double($1.calories) ?? 0) }
    }
    private var totalDishWeight: Double {
        ingredients.reduce(0) { $0 + (Double($1.weightGrams) ?? 0) }
    }
    private var computedServingCalories: Double? {
        guard totalDishWeight > 0, let servingWeight = Double(servingWeightGrams) else { return nil }
        return totalIngredientCalories * (servingWeight / totalDishWeight)
    }

    var body: some View {
        Form {
            Section("Dish") {
                TextField("Dish name", text: $dishName)
            }

            Section("Ingredients") {
                ForEach($ingredients) { $row in
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Ingredient (e.g. ground beef)", text: $row.name)
                        HStack {
                            TextField("Calories", text: $row.calories).keyboardType(.decimalPad)
                            TextField("Weight (g)", text: $row.weightGrams).keyboardType(.decimalPad)
                        }
                    }
                }
                .onDelete { ingredients.remove(atOffsets: $0) }

                Button {
                    ingredients.append(IngredientRow())
                } label: {
                    Label("Add ingredient", systemImage: "plus")
                }
            }

            Section("Serving") {
                TextField("Serving weight eaten (g)", text: $servingWeightGrams)
                    .keyboardType(.decimalPad)

                if let computed = computedServingCalories {
                    Text("Computed: \(Int(computed)) kcal")
                        .font(.subheadline.bold())
                } else {
                    Text("Enter ingredient calories/weights and a serving weight.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Override") {
                Toggle("Override calorie count", isOn: $useOverride)
                if useOverride {
                    TextField("Calories", text: $overrideCalories)
                        .keyboardType(.decimalPad)
                }
            }

            Button("Save") { save() }
                .buttonStyle(.borderedProminent)
                .disabled(dishName.trimmingCharacters(in: .whitespaces).isEmpty || finalCalories == nil)
        }
    }

    private var finalCalories: Double? {
        if useOverride {
            return Double(overrideCalories)
        }
        return computedServingCalories
    }

    private func save() {
        guard let calories = finalCalories else { return }
        let entry = FoodEntry(
            name: dishName,
            calories: calories,
            source: useOverride ? .manualOverride : .ingredientCalc,
            servingDescription: "\(servingWeightGrams)g serving"
        )
        modelContext.insert(entry)
        onSaved()
    }
}
