import Foundation
import SwiftData

enum FoodEntrySource: String, Codable {
    case database
    case ingredientCalc
    case manualOverride
}

@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var date: Date
    var calories: Double
    var sourceRaw: String
    var servingDescription: String

    var source: FoodEntrySource {
        get { FoodEntrySource(rawValue: sourceRaw) ?? .manualOverride }
        set { sourceRaw = newValue.rawValue }
    }

    init(name: String, date: Date = .now, calories: Double, source: FoodEntrySource, servingDescription: String = "") {
        self.id = UUID()
        self.name = name
        self.date = date
        self.calories = calories
        self.sourceRaw = source.rawValue
        self.servingDescription = servingDescription
    }
}
