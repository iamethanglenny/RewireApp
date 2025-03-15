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

- **StorageManager.swift**: Core storage manager for data persistence
- **AppState.swift**: Main app state coordinator

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
2. View models update data through the StorageManager
3. StorageManager persists data to disk
4. Changes are published back to view models through Combine
5. UI updates reactively based on published changes

## Adding New Features

To add new features to the storage system:

1. Add new model types to the appropriate model file
2. Add storage methods to StorageManager
3. Add view model methods to the appropriate view model
4. Expose functionality through AppState if needed 