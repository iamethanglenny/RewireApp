# Rewire App Tests

This directory contains test files for the Rewire app's storage system.

## Core Data Testing

The `CoreDataTest.swift` file demonstrates how to test Core Data functionality in the Rewire app. It includes:

- A `TestPersistenceController` that creates an in-memory Core Data stack for testing
- A sample test function that accesses the DailyLog entity

## Using the Test Infrastructure

To use the Core Data test infrastructure in your own tests:

1. Import the necessary frameworks:
   ```swift
   import Foundation
   import CoreData
   ```

2. Use the `TestPersistenceController` to create an in-memory Core Data stack:
   ```swift
   let context = TestPersistenceController.shared.container.viewContext
   ```

3. Create and execute fetch requests:
   ```swift
   let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
   let results = try context.fetch(fetchRequest)
   ```

## Running Tests

To run the tests:

1. Open the Xcode project
2. Select the test target
3. Press Cmd+U to run all tests, or Cmd+Ctrl+Option+U to run a specific test

## Notes on Core Data Testing

- The `TestPersistenceController` uses an in-memory store, which is faster and doesn't persist data between test runs
- Each test should create its own test data and clean up afterward
- For more complex tests, you may want to create a dedicated test database with predefined test data 