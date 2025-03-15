#!/bin/bash

# Script to run Core Data tests

echo "Running Core Data tests..."

# Create a Swift file to run the tests
cat > run_tests.swift << EOF
import Foundation

// Import the test file
#if canImport(Rewire)
import Rewire
#endif

// Run the tests
print("Starting Core Data tests...")
runAllCoreDataTests()
EOF

# Run the Swift file
echo "Executing tests..."
swift run_tests.swift

# Clean up
rm run_tests.swift

echo "Tests completed." 