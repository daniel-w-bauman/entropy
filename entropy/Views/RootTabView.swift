import SwiftUI
import SwiftData

struct RootTabView: View {
    @Query private var settingsList: [AppSettings]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today", systemImage: "sun.max") }

            WeightLogView()
                .tabItem { Label("Weight", systemImage: "chart.line.uptrend.xyaxis") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .task {
            ensureSettingsExist()
        }
    }

    private func ensureSettingsExist() {
        if settingsList.isEmpty {
            modelContext.insert(AppSettings())
        }
    }
}
