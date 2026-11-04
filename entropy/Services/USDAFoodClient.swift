import Foundation

struct USDAFoodResult: Identifiable {
    let id: Int
    let description: String
    let caloriesPerServing: Double
    let servingDescription: String
}

enum USDAFoodClientError: Error {
    case missingAPIKey
    case invalidResponse
    case requestFailed(Int)
}

/// Thin client for USDA FoodData Central's search endpoint.
/// https://fdc.nal.usda.gov/api-guide
final class USDAFoodClient {
    private let session: URLSession
    private let apiKey: String

    /// The API key is read from `APIKeys.plist` (gitignored) under key `USDA_API_KEY`,
    /// so it is never committed to source control.
    init(session: URLSession = .shared) {
        self.apiKey = Self.loadAPIKey() ?? ""
        self.session = session
    }

    private static func loadAPIKey() -> String? {
        guard let url = Bundle.main.url(forResource: "APIKeys", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] else {
            return nil
        }
        return plist["USDA_API_KEY"]
    }

    func search(query: String) async throws -> [USDAFoodResult] {
        guard !apiKey.isEmpty else { throw USDAFoodClientError.missingAPIKey }

        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "25")
        ]
        guard let url = components.url else { throw USDAFoodClientError.invalidResponse }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else { throw USDAFoodClientError.invalidResponse }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw USDAFoodClientError.requestFailed(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(USDASearchResponse.self, from: data)
        return decoded.foods.compactMap { food in
            guard let kcal = food.foodNutrients.first(where: { $0.nutrientName == "Energy" && $0.unitName == "KCAL" })?.value else {
                return nil
            }
            let servingDescription = food.servingSize != nil && food.servingSizeUnit != nil
                ? "\(food.servingSize!) \(food.servingSizeUnit!)"
                : "100 g"
            return USDAFoodResult(
                id: food.fdcId,
                description: food.description,
                caloriesPerServing: kcal,
                servingDescription: servingDescription
            )
        }
    }
}

private struct USDASearchResponse: Decodable {
    let foods: [USDAFood]
}

private struct USDAFood: Decodable {
    let fdcId: Int
    let description: String
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [USDAFoodNutrient]
}

private struct USDAFoodNutrient: Decodable {
    let nutrientName: String
    let unitName: String
    let value: Double
}
