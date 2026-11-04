# Calorie & Weight Tracker — Spec

## Overview
A native iOS app for tracking daily calorie intake, exercise calories burned, and body weight over time, with goal-setting and progress visualization. All data is stored locally on-device — no accounts, no backend, no cloud sync.

## Platform & Tech Stack
- **Platform:** iOS only
- **Stack:** Swift + SwiftUI
- **Storage:** Local-only (SwiftData or Core Data), no backend, no user accounts
- **Charts:** Swift Charts for trend visualizations

## Core Features

### 1. Food Logging
Two entry modes, both overridable with a manual calorie count:

**Mode A — Database Search**
- User searches a dish/food by name (e.g. "chow mein").
- Results pulled from **USDA FoodData Central** (free API, requires a free API key).
- User selects a result and a serving size/quantity; app records the calorie value for that entry.
- User can override the returned calorie value before saving.

**Mode B — Ingredient-Based Recipe Calculation**
- User enters a list of ingredients with their individual calorie counts (e.g. "1 container pasta — 1600 cal", "butter — 100 cal", "1 lb 85% ground beef — 975 cal") and the ingredient's weight.
- User enters the serving weight they actually ate (e.g. "250 grams of the dish").
- App computes: `calories_for_serving = total_ingredient_calories × (serving_weight / total_dish_weight)`, where `total_dish_weight` is the sum of all ingredient weights.
- Result is shown to the user, who can override with their own calorie count before saving.

**Common to both modes**
- Every logged food entry stores: name/description, date & time, calorie count (computed or overridden), and which mode was used.
- Entries can be edited or deleted after the fact.

### 2. Exercise Logging
- Manual entry only: activity name + calories burned, entered directly by the user (no database or HealthKit integration in v1).
- Exercise entries have a date/time and can be edited or deleted.
- Daily net calories = calories consumed − calories burned from exercise. This net figure is used for daily/weekly summaries.

### 3. Weight Tracking
- User logs weight entries over time (date + weight value).
- Weight entries can be edited or deleted.
- **Trend chart:** line graph of weight over time, with daily/weekly/monthly view options.
- **Goal weight + target date:** user sets a target weight and a target date; app shows progress toward the goal.
- **Suggested daily calorie target:** app computes a recommended daily calorie intake based on current weight, goal weight, and the timeline to the target date (using a standard calories-per-pound-of-bodyweight-change estimate, e.g. ~3500 kcal ≈ 1 lb).

### 4. Daily/Summary View
- Dashboard showing: today's logged food entries, today's exercise entries, total calories consumed, total calories burned, net calories, and progress against the suggested daily target.
- History view to browse past days.

### 5. Units
- User can choose **imperial or metric** in Settings, applied globally (weight in lb/kg, ingredient/food amounts in oz/g).
- Unit preference is stored locally and can be changed at any time; existing entries display converted to the current unit preference.

### 6. Reminders / Notifications
- Local push notifications (no server) reminding the user to log meals and/or weight, at user-configurable times.

### 7. Data Export
- Export all logged data (food entries, exercise entries, weight entries) as CSV or JSON to a file the user can save/share via the iOS share sheet.

## Data Model (high-level)
- **FoodEntry**: id, name, date, calories, source (database/ingredient-calc/manual override), servingDescription
- **ExerciseEntry**: id, activityName, date, caloriesBurned
- **WeightEntry**: id, date, weightValue (stored in a canonical unit, displayed per user preference)
- **Goal**: targetWeight, targetDate, startWeight, startDate
- **Settings**: unitPreference (imperial/metric), reminderTimes

## Out of Scope (v1)
- User accounts / cloud sync / multi-device support
- Barcode scanning or photo/AI food recognition
- Macro tracking (protein/carbs/fat) — calories only
- Apple Health / HealthKit integration
- Android or other platforms

## Open Questions / Future Considerations
- USDA FoodData Central requires a free API key — needs to be obtained and stored securely (e.g. in app config, not committed to source control).
- Consider macro tracking as a fast-follow if calorie-only tracking proves insufficient.
- Consider HealthKit sync for exercise as a fast-follow.
