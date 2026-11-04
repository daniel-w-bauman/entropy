import Foundation
import SwiftData

@Model
final class ExerciseEntry {
    var id: UUID
    var activityName: String
    var date: Date
    var caloriesBurned: Double

    init(activityName: String, date: Date = .now, caloriesBurned: Double) {
        self.id = UUID()
        self.activityName = activityName
        self.date = date
        self.caloriesBurned = caloriesBurned
    }
}
