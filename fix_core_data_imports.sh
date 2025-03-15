#!/bin/bash

# Script to help fix Core Data import issues

echo "This script will help you fix Core Data import issues in your Xcode project."
echo ""

# Check if the Core Data model file exists
MODEL_PATH="Rewire/Storage/CoreData/RewireModel.xcdatamodeld"
if [ ! -d "$MODEL_PATH" ]; then
    echo "Error: Core Data model file not found at $MODEL_PATH"
    echo "Please make sure you've created the Core Data model file."
    exit 1
fi

# Create directories if they don't exist
mkdir -p Rewire/Storage/CoreData/Sources/RewireCoreData

echo "1. Creating a module map file to help with imports..."
cat > Rewire/Storage/CoreData/module.modulemap << EOF
module RewireCoreData {
    header "Sources/RewireCoreData/RewireCoreData.h"
    export *
}
EOF

echo "2. Creating a header file for the module..."
cat > Rewire/Storage/CoreData/Sources/RewireCoreData/RewireCoreData.h << EOF
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Expose PersistenceController to Objective-C
@interface PersistenceController : NSObject
+ (instancetype)shared;
@property (nonatomic, strong, readonly) NSPersistentContainer *container;
- (instancetype)initWithInMemory:(BOOL)inMemory;
- (void)save;
- (NSManagedObjectContext *)backgroundContext;
@end
EOF

echo "3. Updating the CoreDataTest.swift file..."
cat > Rewire/Storage/Tests/CoreDataTest.swift << EOF
import Foundation
import CoreData

// Simple wrapper for PersistenceController to use in tests
// This avoids the need for complex imports
struct TestPersistenceController {
    static let shared = TestPersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = true) {
        container = NSPersistentContainer(name: "RewireModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

func testDailyLogAccess() {
    // This is just to test compilation
    let context = TestPersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
    do {
        let _ = try context.fetch(fetchRequest)
        print("DailyLog is accessible")
    } catch {
        print("Error: \(error)")
    }
}

// Main function to run all Core Data tests
func runAllCoreDataTests() {
    print("Running basic DailyLog access test...")
    testDailyLogAccess()
    
    print("\\nAll Core Data tests completed.")
}
EOF

echo ""
echo "Files have been created/updated. Now you need to:"
echo ""
echo "1. Add the Core Data model file to your Xcode project:"
echo "   - Right-click in the Project Navigator"
echo "   - Select 'Add Files to \"Rewire\"...'"
echo "   - Navigate to and select $MODEL_PATH"
echo "   - Ensure 'Copy items if needed' is UNCHECKED"
echo "   - Make sure your main app target is selected"
echo "   - Click 'Add'"
echo ""
echo "2. Add the PersistenceController.swift file to your Xcode project"
echo ""
echo "3. Add the CoreDataManager.swift file to your Xcode project"
echo ""
echo "4. In your Xcode project settings:"
echo "   - Select your project in the Project Navigator"
echo "   - Select your target"
echo "   - Go to 'Build Settings'"
echo "   - Search for 'Import Paths'"
echo "   - Add the path to your Core Data directory: $(pwd)/Rewire/Storage/CoreData"
echo ""
echo "5. Clean and rebuild your project (Cmd+Shift+K, then Cmd+B)"
echo ""
echo "After completing these steps, the 'No such module' error should be resolved."

# Make the script executable
chmod +x fix_core_data_imports.sh 