# Core Data Examples

This directory contains example views and code snippets that demonstrate how to use Core Data in the Rewire app.

## Examples

- **CoreDataExampleView.swift**: A simple view that demonstrates how to:
  - Fetch and display data from Core Data using `@FetchRequest`
  - Add new records to Core Data
  - Delete records from Core Data
  - Work with relationships (DailyLog -> WellbeingRatings)

## Usage

To use these examples in your app:

1. Add the example files to your Xcode project
2. Make sure the Core Data stack is properly initialized in your app
3. Navigate to the example views to see Core Data in action

## Key Concepts

### Accessing the Managed Object Context

```swift
@Environment(\.managedObjectContext) private var viewContext
```

### Fetching Data

```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)],
    animation: .default)
private var dailyLogs: FetchedResults<DailyLog>
```

### Creating New Records

```swift
let newLog = DailyLog(context: viewContext)
newLog.id = UUID().uuidString
newLog.date = Date()
// Set other properties...

try viewContext.save()
```

### Deleting Records

```swift
viewContext.delete(recordToDelete)
try viewContext.save()
```

### Working with Relationships

```swift
// Create related entity
let ratings = WellbeingRatings(context: viewContext)
ratings.id = UUID().uuidString
// Set properties...

// Establish relationship
ratings.dailyLog = newLog
newLog.wellbeingRatings = ratings
```

## Additional Resources

- [Apple's Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [Core Data with SwiftUI Tutorial](https://developer.apple.com/tutorials/swiftui/persisting-data) 