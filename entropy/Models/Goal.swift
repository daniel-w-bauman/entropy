import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var targetWeightInGrams: Double
    var targetDate: Date
    var startWeightInGrams: Double
    var startDate: Date

    init(targetWeightInGrams: Double, targetDate: Date, startWeightInGrams: Double, startDate: Date = .now) {
        self.id = UUID()
        self.targetWeightInGrams = targetWeightInGrams
        self.targetDate = targetDate
        self.startWeightInGrams = startWeightInGrams
        self.startDate = startDate
    }
}
