# Implementation Plan

App name: **entropy** · Bundle id: `com.danielbauman.entropy` · Target: iOS 17+ · Stack: Swift + SwiftUI + SwiftData

Reference: see [spec.md](spec.md) for full requirements. This doc tracks build order and file-level breakdown only.

## 1. Project Scaffold
- `entropy.xcodeproj` + `entropyApp.swift` (App entry point)
- Folder structure: `Models/`, `Views/`, `Services/`, `Utilities/`
- SwiftData `ModelContainer` wired up in the App struct

## 2. Data Models (SwiftData `@Model` classes)
- `FoodEntry`: id, name, date, calories, source enum (.database/.ingredientCalc/.manualOverride), servingDescription
- `ExerciseEntry`: id, activityName, date, caloriesBurned
- `WeightEntry`: id, date, weightInGrams (canonical unit; convert for display)
- `Goal`: targetWeightInGrams, targetDate, startWeightInGrams, startDate
- `AppSettings`: unitPreference enum (.imperial/.metric), reminderTimes

## 3. USDA FoodData Central Client
- `Services/USDAFoodClient.swift`: async search function hitting `api.nal.usda.gov/fdc/v1/foods/search`
- API key stored in a local, gitignored config (not committed)
- Model the subset of the response we need (description, servings/nutrients → kcal)

## 4. Food Logging
- `FoodSearchView`: search bar → USDA results list → pick result + serving qty → override calorie field → save
- `IngredientCalcView`: dynamic list of ingredient rows (name, calories, weight), serving-weight input, live-computed result, override field → save
- Shared `FoodEntryFormSheet` wrapper for both modes

## 5. Exercise Logging
- `ExerciseLogView`: simple form (activity name, calories burned, date) → save/edit/delete

## 6. Weight Tracking + Goals
- `WeightLogView`: entry form + list (edit/delete)
- `WeightTrendChartView`: Swift Charts line graph, daily/weekly/monthly toggle
- `GoalSettingsView`: target weight + date picker
- `CalorieTargetCalculator` (Utilities): computes suggested daily calorie target from current weight, goal weight, timeline (~3500 kcal/lb)

## 7. Dashboard & History
- `DashboardView`: today's food + exercise entries, totals, net calories, progress vs. target
- `HistoryView`: browse past days

## 8. Settings, Reminders, Export
- `SettingsView`: unit toggle (imperial/metric), reminder time pickers
- `NotificationScheduler` (Utilities): local `UNUserNotificationCenter` reminders
- `ExportService`: serialize all entries to CSV/JSON, present iOS share sheet

## 9. Build Verification
- Open in Xcode, resolve any project-file issues, confirm it builds/runs in Simulator

## Notes
- Each milestone above = roughly one commit.
- Macro tracking, HealthKit, barcode/photo recognition, accounts/sync are explicitly out of scope per spec.md.
