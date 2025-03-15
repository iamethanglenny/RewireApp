# RewireApp
Rewire is the #1 science-backed app to help people quit vaping.

## Features

- Track days since quitting vaping
- Visualize progress with an engaging hourglass design
- Monitor health improvements and money saved
- Access daily challenges to stay motivated
- Get support and resources for your journey

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/rewire-app.git
```

2. Open the project in Xcode:
```bash
cd rewire-app
open Rewire.xcodeproj
```

3. Select your development team in the Signing & Capabilities tab.

4. Build and run the app (⌘+R) on your device or simulator.

## App Structure

- **HomeView**: Main dashboard showing your progress metrics
- **RewiringView**: Information about the brain's recovery process
- **ProfileView**: User profile and settings

## Project Structure

The Rewire app is organized into the following directories:

- **Rewire/**: Main app directory
  - **Rewire/**: Main app source files
  - **Views/**: SwiftUI views for different screens
  - **Components/**: Reusable UI components
  - **Extensions/**: Swift extensions for UI-related functionality
  - **Shared/**: Shared types and utilities used across modules
  - **Storage/**: Core storage system
    - **Models/**: Data models using SwiftData
    - **ViewModels/**: View models for connecting storage to UI
    - **Extensions/**: Utility extensions for storage functionality
    - **SwiftDataManager.swift**: SwiftData implementation for persistent storage
  - **Tests/**: Unit and UI tests

## Setup Instructions

1. Clone the repository
2. Open Rewire.xcodeproj in Xcode
3. Make sure all directories are added to the main app target:
   - Right-click in the Project Navigator
   - Select "Add Files to 'Rewire'..."
   - Navigate to and select any missing directories (Storage, Shared, etc.)
   - Ensure "Copy items if needed" is unchecked
   - Make sure your main app target is selected
   - Click "Add"
4. Build and run the app

## Data Storage

The app uses SwiftData for persistent storage of user data, challenges, daily logs, and more. The SwiftData implementation includes:

- A complete data model with entities for User, Challenge, DailyLog, etc.
- Relationships between entities to maintain data integrity
- A migration path from the previous file-based storage system
- A SwiftDataManager class for simplified CRUD operations

SwiftData provides several advantages:
- Swift-native API with macros for model definition
- Better performance with larger datasets
- Robust relationship management
- Support for complex queries
- Automatic schema migration

For more details on the SwiftData implementation, see the [Storage README](Rewire/Storage/README.md).

## Support

For questions or support, please contact support@rewireapp.com

## License

This project is licensed under the MIT License - see the LICENSE file for details.
