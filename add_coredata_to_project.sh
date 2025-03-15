#!/bin/bash

# Script to help add Core Data files to the Xcode project

echo "This script will help you add Core Data files to your Xcode project."
echo "Please follow these steps manually in Xcode:"
echo ""
echo "1. Open your Xcode project (Rewire.xcodeproj)"
echo ""
echo "2. Add the CoreData directory to your project:"
echo "   - Right-click in the Project Navigator"
echo "   - Select 'Add Files to \"Rewire\"...'"
echo "   - Navigate to: $(pwd)/Rewire/Storage/CoreData"
echo "   - Ensure 'Copy items if needed' is UNCHECKED"
echo "   - Make sure your main app target is selected"
echo "   - Click 'Add'"
echo ""
echo "3. Make sure the Core Data model file is properly added:"
echo "   - If RewireModel.xcdatamodeld doesn't appear in the Project Navigator,"
echo "     add it separately using the same process"
echo "   - The model file is located at: $(pwd)/Rewire/Storage/CoreData/RewireModel.xcdatamodeld"
echo ""
echo "4. Verify that the PersistenceController.swift file is included in your target:"
echo "   - Select the file in the Project Navigator"
echo "   - Open the File Inspector (right panel)"
echo "   - Under 'Target Membership', make sure your main app target is checked"
echo ""
echo "5. Do the same for CoreDataManager.swift and any other Core Data related files"
echo ""
echo "6. Clean and rebuild your project (Cmd+Shift+K, then Cmd+B)"
echo ""
echo "After completing these steps, the 'No such module' error should be resolved."
echo ""
echo "If you're still having issues, you may need to modify your import statement to match your project structure."
echo "Try using just 'import Rewire' instead of 'import Rewire.Storage.CoreData'"

# Make the script executable
chmod +x add_coredata_to_project.sh 