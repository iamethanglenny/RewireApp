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

- **CoreData/**: Core Data implementation for persistent storage
  - `PersistenceController.swift`: Manages the Core Data stack
  - `CoreDataManager.swift`: CRUD operations for Core Data entities
  - `RewireModel.xcdatamodeld`: Core Data model file

- **StorageManager.swift**: Core storage manager for data persistence
- **AppState.swift**: Main app state coordinator

## Storage Implementation

The app supports two storage implementations:

1. **File-based Storage**: The original implementation that uses JSON files for data persistence.
2. **Core Data Storage**: A newer implementation that uses Core Data for more robust data management.

The Core Data implementation provides several advantages:
- Better performance with larger datasets
- Robust relationship management
- Support for complex queries
- Background processing capabilities
- Automatic migration support

See the [Core Data README](CoreData/README.md) for more details on the Core Data implementation.

## Usage

The storage system is designed to be used through the `AppState` class, which provides a centralized access point to all view models and data.

```swift
// Access the app state
let appState = AppState.shared

// User management
appState.userViewModel.updateUserProfile(name: "John")

// Challenge management
appState.challengeViewModel.startChallenge(challengeId: "challenge-id")

// Tracking
appState.trackingViewModel.saveDailyLog(stayedClean: true, wellbeingRatings: ratings)
```

## Data Flow

1. UI components interact with view models
2. View models update data through the StorageManager or CoreDataManager
3. Data is persisted to disk (either as JSON files or in the Core Data store)
4. Changes are published back to view models through Combine
5. UI updates reactively based on published changes

## Migrating to Core Data

To migrate from the file-based storage to Core Data:

1. Ensure the Core Data files are added to your Xcode project
2. Uncomment the migration line in RewireApp.swift:
   ```swift
   CoreDataManager.shared.migrateFromFileStorage(storageManager: StorageManager.shared)
   ```
3. Run the app once to perform the migration
4. After successful migration, you can comment out the migration line

## Adding New Features

To add new features to the storage system:

1. Add new model types to the appropriate model file
2. Add storage methods to StorageManager and/or CoreDataManager
3. Add view model methods to the appropriate view model
4. Expose functionality through AppState if needed 