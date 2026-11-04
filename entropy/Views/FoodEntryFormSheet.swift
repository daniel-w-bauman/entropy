import SwiftUI

struct FoodEntryFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    private enum Mode: String, CaseIterable, Identifiable {
        case search = "Search"
        case ingredients = "Ingredients"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .search

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding()

                switch mode {
                case .search:
                    FoodSearchView(onSaved: { dismiss() })
                case .ingredients:
                    IngredientCalcView(onSaved: { dismiss() })
                }
            }
            .navigationTitle("Log Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
