#!/bin/bash

# Rewire App Setup Script
# This script helps organize the project structure and fix common issues

echo "Rewire App Setup Script"
echo "======================="
echo

# Check if the script is run from the project root
if [ ! -d "Rewire" ]; then
  echo "Error: This script must be run from the project root directory"
  echo "Please cd to the directory containing the Rewire folder and try again"
  exit 1
fi

# Create directories if they don't exist
echo "Creating directory structure..."
mkdir -p Rewire/Shared
mkdir -p Rewire/Storage/Models
mkdir -p Rewire/Storage/ViewModels
mkdir -p Rewire/Storage/Extensions
mkdir -p Rewire/Views
mkdir -p Rewire/Components
mkdir -p Rewire/Extensions
mkdir -p Rewire/Tests

# Check for duplicate files
echo "Checking for duplicate files..."
if [ -f "Rewire/Extensions/Color+Hex.swift" ] && [ -f "Rewire/Storage/Extensions/Color+Hex.swift" ]; then
  echo "Warning: Duplicate Color+Hex.swift files found"
  echo "  - Rewire/Extensions/Color+Hex.swift"
  echo "  - Rewire/Storage/Extensions/Color+Hex.swift"
  echo "Please manually resolve this duplication in Xcode"
fi

# Check for temporary AppState.swift
if [ -f "Rewire/Rewire/AppState.swift" ]; then
  echo "Warning: Temporary AppState.swift found in Rewire/Rewire"
  echo "Please make sure the Storage directory is added to your Xcode project target"
  echo "Then you can delete the temporary file: Rewire/Rewire/AppState.swift"
fi

echo
echo "Setup complete!"
echo
echo "Next steps:"
echo "1. Open Rewire.xcodeproj in Xcode"
echo "2. Add all directories to your main app target:"
echo "   - Right-click in the Project Navigator"
echo "   - Select \"Add Files to 'Rewire'...\""
echo "   - Navigate to and select any missing directories (Storage, Shared, etc.)"
echo "   - Ensure \"Copy items if needed\" is unchecked"
echo "   - Make sure your main app target is selected"
echo "   - Click \"Add\""
echo "3. Build and run the app"
echo
echo "For more information, see the README.md file" 