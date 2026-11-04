import Foundation

enum ExportFormat {
    case csv
    case json
}

struct ExportService {
    static func export(foodEntries: [FoodEntry], exerciseEntries: [ExerciseEntry], weightEntries: [WeightEntry], format: ExportFormat) -> URL? {
        let data: Data
        let filename: String

        switch format {
        case .csv:
            data = Data(buildCSV(foodEntries: foodEntries, exerciseEntries: exerciseEntries, weightEntries: weightEntries).utf8)
            filename = "entropy-export.csv"
        case .json:
            guard let jsonData = try? buildJSONData(foodEntries: foodEntries, exerciseEntries: exerciseEntries, weightEntries: weightEntries) else {
                return nil
            }
            data = jsonData
            filename = "entropy-export.json"
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private static func buildCSV(foodEntries: [FoodEntry], exerciseEntries: [ExerciseEntry], weightEntries: [WeightEntry]) -> String {
        let formatter = ISO8601DateFormatter()
        var lines = ["type,date,name,value,extra"]

        for entry in foodEntries {
            lines.append("food,\(formatter.string(from: entry.date)),\(csvEscape(entry.name)),\(entry.calories),\(csvEscape(entry.servingDescription))")
        }
        for entry in exerciseEntries {
            lines.append("exercise,\(formatter.string(from: entry.date)),\(csvEscape(entry.activityName)),\(entry.caloriesBurned),")
        }
        for entry in weightEntries {
            lines.append("weight,\(formatter.string(from: entry.date)),,\(entry.weightInGrams),grams")
        }
        return lines.joined(separator: "\n")
    }

    private static func csvEscape(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else { return value }
        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private struct ExportPayload: Encodable {
        struct Food: Encodable { let name: String; let date: Date; let calories: Double; let servingDescription: String }
        struct Exercise: Encodable { let activityName: String; let date: Date; let caloriesBurned: Double }
        struct Weight: Encodable { let date: Date; let weightInGrams: Double }

        let food: [Food]
        let exercise: [Exercise]
        let weight: [Weight]
    }

    private static func buildJSONData(foodEntries: [FoodEntry], exerciseEntries: [ExerciseEntry], weightEntries: [WeightEntry]) throws -> Data {
        let payload = ExportPayload(
            food: foodEntries.map { .init(name: $0.name, date: $0.date, calories: $0.calories, servingDescription: $0.servingDescription) },
            exercise: exerciseEntries.map { .init(activityName: $0.activityName, date: $0.date, caloriesBurned: $0.caloriesBurned) },
            weight: weightEntries.map { .init(date: $0.date, weightInGrams: $0.weightInGrams) }
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }
}
