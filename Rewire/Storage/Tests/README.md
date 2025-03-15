# Rewire App Tests

This directory contains test files for the Rewire app's storage system.

## SwiftData Testing

This directory will contain test files for testing SwiftData functionality in the Rewire app.

## Running Tests

To run the tests:

1. Open the Xcode project
2. Select the test target
3. Press Cmd+U to run all tests, or Cmd+Ctrl+Option+U to run a specific test

## Notes on SwiftData Testing

- For testing SwiftData, you should use an in-memory store, which is faster and doesn't persist data between test runs
- Each test should create its own test data and clean up afterward
- For more complex tests, you may want to create a dedicated test database with predefined test data 