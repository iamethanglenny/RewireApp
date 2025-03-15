# Shared Types and Utilities

This directory contains shared types, enums, and utilities that are used across multiple modules in the Rewire app.

## Contents

- `TimePeriod.swift`: An enum representing time periods (week, month, lifetime) used for data filtering and display

## Usage

To use these shared types in your code, you need to:

1. Make sure the Shared directory is added to your Xcode project target
2. Import the specific type in your file if needed (though most Swift files in the same target can access these types without explicit imports)

## Adding New Shared Types

When adding new shared types to this directory, follow these guidelines:

1. Only add types that are used across multiple modules
2. Keep the types simple and focused on a single responsibility
3. Add proper documentation comments to explain the purpose and usage of each type
4. Update this README.md file to document the new type 