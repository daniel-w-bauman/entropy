import Foundation
import SwiftData

@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    /// Canonical storage unit: grams. Convert for display per the user's unit preference.
    var weightInGrams: Double

    init(date: Date = .now, weightInGrams: Double) {
        self.id = UUID()
        self.date = date
        self.weightInGrams = weightInGrams
    }
}
