import Foundation

enum CalorieTargetCalculator {
    /// Standard estimate: ~3500 kcal corresponds to 1 lb of bodyweight change.
    static let kcalPerPound = 3500.0

    /// Suggested daily calorie delta (relative to maintenance) needed to reach
    /// `goal` by its target date, given the current weight.
    /// Positive means a surplus (gaining), negative a deficit (losing).
    static func dailyCalorieDelta(goal: Goal, currentWeightInGrams: Double, today: Date = .now) -> Double? {
        let daysRemaining = Calendar.current.dateComponents([.day], from: today, to: goal.targetDate).day ?? 0
        guard daysRemaining > 0 else { return nil }

        let poundsToChange = UnitConversion.gramsToPounds(goal.targetWeightInGrams - currentWeightInGrams)
        let totalKcalNeeded = poundsToChange * kcalPerPound
        return totalKcalNeeded / Double(daysRemaining)
    }

    /// Suggested daily calorie target = maintenance estimate + delta.
    /// Maintenance here is a simple placeholder the user's logged intake will naturally
    /// calibrate against over time; v1 just surfaces the delta needed for the goal.
    static func suggestedDailyIntake(goal: Goal, currentWeightInGrams: Double, maintenanceCalories: Double, today: Date = .now) -> Double? {
        guard let delta = dailyCalorieDelta(goal: goal, currentWeightInGrams: currentWeightInGrams, today: today) else {
            return nil
        }
        return maintenanceCalories + delta
    }

    /// Rough maintenance-calorie estimate (~15 kcal per lb of bodyweight, a common
    /// moderate-activity rule of thumb). Used as a default when the user hasn't
    /// provided a better maintenance figure.
    static func roughMaintenanceEstimate(currentWeightInGrams: Double) -> Double {
        UnitConversion.gramsToPounds(currentWeightInGrams) * 15.0
    }
}
