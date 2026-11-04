import Foundation
import SwiftData

enum UnitPreference: String, Codable, CaseIterable {
    case imperial
    case metric
}

/// Singleton-style settings record. The app ensures exactly one instance exists.
@Model
final class AppSettings {
    var id: UUID
    var unitPreferenceRaw: String
    var mealReminderEnabled: Bool
    var mealReminderTime: Date
    var weightReminderEnabled: Bool
    var weightReminderTime: Date

    var unitPreference: UnitPreference {
        get { UnitPreference(rawValue: unitPreferenceRaw) ?? .imperial }
        set { unitPreferenceRaw = newValue.rawValue }
    }

    init(unitPreference: UnitPreference = .imperial) {
        self.id = UUID()
        self.unitPreferenceRaw = unitPreference.rawValue
        self.mealReminderEnabled = false
        self.mealReminderTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now) ?? .now
        self.weightReminderEnabled = false
        self.weightReminderTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    }
}
