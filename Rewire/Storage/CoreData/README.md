# Core Data Implementation for Rewire App

This directory contains the Core Data implementation for the Rewire app, which provides a robust and efficient way to store and manage app data.

## Files

- **PersistenceController.swift**: Manages the Core Data stack, including the persistent container and context.
- **CoreDataManager.swift**: Provides methods for CRUD operations on Core Data entities, as well as migration from the file-based storage system.
- **RewireModel.xcdatamodeld**: The Core Data model file that defines the entities, attributes, and relationships.

## Setup Instructions

1. Make sure the CoreData directory is added to your Xcode project:
   - Right-click in the Project Navigator
   - Select "Add Files to 'Rewire'..."
   - Navigate to and select the CoreData directory
   - Ensure "Copy items if needed" is unchecked
   - Make sure your main app target is selected
   - Click "Add"

2. Ensure the RewireModel.xcdatamodeld file is properly added to your project:
   - If it doesn't appear in the Project Navigator, add it separately
   - Make sure it's included in your app target

3. Initialize the Core Data stack in your app:
   - The RewireApp.swift file has been updated to initialize the Core Data stack
   - It also provides the managed object context to the SwiftUI environment

## Migration from File Storage

The CoreDataManager includes a method to migrate data from the file-based storage system to Core Data:

```swift
CoreDataManager.shared.migrateFromFileStorage(storageManager: StorageManager.shared)
```

This method should be called once when you're ready to migrate your data. It's currently commented out in the RewireApp.swift file.

## Usage

To use Core Data in your views and view models:

1. Access the managed object context from the environment:

```swift
@Environment(\.managedObjectContext) private var viewContext
```

2. Use the CoreDataManager for common operations:

```swift
let dailyLog = CoreDataManager.shared.getDailyLog(for: Date())
```

3. For more complex operations, you can use the PersistenceController directly:

```swift
let backgroundContext = PersistenceController.shared.backgroundContext()
```

## Entity Relationships

The Core Data model includes the following entities and relationships:

- **DailyLog**: Represents a daily log entry
  - Has one WellbeingRatings
  - Has many CravingRecords
  - Belongs to one User

- **Challenge**: Represents a challenge
  - Has many ChallengeTasks
  - Has many UserChallenges

- **User**: Represents a user
  - Has many DailyLogs
  - Has many UserChallenges

- **UserChallenge**: Represents a user's progress on a challenge
  - Belongs to one User
  - Belongs to one Challenge

## Notes

- The Core Data model uses class generation for entities, which means you can use the generated classes directly in your code.
- The model includes transformable attributes for complex data types, such as dictionaries.
- Relationships are set up with appropriate deletion rules to maintain data integrity. 