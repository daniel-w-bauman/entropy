import Foundation

/// All weight is stored canonically in grams. These helpers convert for display/input only.
enum UnitConversion {
    static let gramsPerPound = 453.59237
    static let gramsPerKilogram = 1000.0

    static func gramsToPounds(_ grams: Double) -> Double { grams / gramsPerPound }
    static func poundsToGrams(_ pounds: Double) -> Double { pounds * gramsPerPound }

    static func gramsToKilograms(_ grams: Double) -> Double { grams / gramsPerKilogram }
    static func kilogramsToGrams(_ kilograms: Double) -> Double { kilograms * gramsPerKilogram }

    static func displayWeight(grams: Double, preference: UnitPreference) -> Double {
        switch preference {
        case .imperial: return gramsToPounds(grams)
        case .metric: return gramsToKilograms(grams)
        }
    }

    static func gramsFromDisplayWeight(_ value: Double, preference: UnitPreference) -> Double {
        switch preference {
        case .imperial: return poundsToGrams(value)
        case .metric: return kilogramsToGrams(value)
        }
    }

    static func weightUnitLabel(_ preference: UnitPreference) -> String {
        switch preference {
        case .imperial: return "lb"
        case .metric: return "kg"
        }
    }

    static func massUnitLabel(_ preference: UnitPreference) -> String {
        switch preference {
        case .imperial: return "oz"
        case .metric: return "g"
        }
    }

    static let gramsPerOunce = 28.349523125

    static func displayMass(grams: Double, preference: UnitPreference) -> Double {
        switch preference {
        case .imperial: return grams / gramsPerOunce
        case .metric: return grams
        }
    }

    static func gramsFromDisplayMass(_ value: Double, preference: UnitPreference) -> Double {
        switch preference {
        case .imperial: return value * gramsPerOunce
        case .metric: return value
        }
    }
}
