import SwiftUI
import SwiftData

@main
struct entropyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FoodEntry.self,
            ExerciseEntry.self,
            WeightEntry.self,
            Goal.self,
            AppSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
