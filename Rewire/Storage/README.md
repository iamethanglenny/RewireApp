# Rewire App Storage System

This directory contains the core storage system for the Rewire app, which helps users track and overcome addictions.

## Directory Structure

- **Models/**: Data models for the app
  - `User.swift`: User profile and settings
  - `DailyLog.swift`: Daily tracking logs and craving records
  - `Challenge.swift`: Challenges and tasks
  - `Recovery.swift`: Recovery milestones and progress

- **Extensions/**: Utility extensions
  - `Color+Hex.swift`: Extension for creating colors from hex values
  - `Date+Extensions.swift`: Date utility extensions

- **ViewModels/**: View models for connecting storage to UI
  - `UserViewModel.swift`: Manages user data and profile
  - `ChallengeViewModel.swift`: Manages challenges and tasks
  - `TrackingViewModel.swift`: Manages daily logs and cravings

- **SwiftDataManager.swift**: Core storage manager for SwiftData persistence
- **StorageManager.swift**: Legacy storage manager for file-based persistence
- **AppState.swift**: Main app state coordinator

## Storage Implementation

The app supports two storage implementations:

1. **File-based Storage**: The original implementation that uses JSON files for data persistence.
2. **SwiftData Storage**: A newer implementation that uses SwiftData for more robust data management.

The SwiftData implementation provides several advantages:
- Better performance with larger datasets
- Robust relationship management
- Support for complex queries
- Background processing capabilities
- Automatic migration support
- Swift-native API with macros

## Usage

The storage system is designed to be used through the `AppState` class, which provides a centralized access point to all view models and data.

```swift
// Access the app state
let appState = AppState.shared

// User management
appState.userViewModel.updateUser(name: "John")

// Challenge management
appState.challengeViewModel.startChallenge(challengeId: "challenge-id")

// Tracking
appState.trackingViewModel.saveDailyLog(stayedClean: true, wellbeingRatings: ratings)
```

## Data Flow

1. UI components interact with view models
2. View models update data through the SwiftDataManager
3. Data is persisted to disk using SwiftData
4. Changes are published back to view models through Combine
5. UI updates reactively based on published changes

## Migrating to SwiftData

To migrate from the file-based storage to SwiftData:

1. Uncomment the migration line in RewireApp.swift:
   ```swift
   SwiftDataManager.shared.migrateFromFileStorage(storageManager: StorageManager.shared)
   ```
2. Run the app once to perform the migration
3. After successful migration, you can comment out the migration line

## Adding New Features

To add new features to the storage system:

1. Add new model types to the appropriate model file using the `@Model` macro
2. Add storage methods to SwiftDataManager
3. Add view model methods to the appropriate view model
4. Expose functionality through AppState if needed 