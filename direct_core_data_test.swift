import Foundation
import CoreData

// Simple wrapper for PersistenceController to use in tests
struct TestPersistenceController {
    static let shared = TestPersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = true) {
        // Create a model description
        let managedObjectModel = createManagedObjectModel()
        
        // Initialize the persistent container with the model
        container = NSPersistentContainer(name: "RewireModel", managedObjectModel: managedObjectModel)
        
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
    
    // Create a managed object model programmatically for testing
    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create DailyLog entity
        let dailyLogEntity = NSEntityDescription()
        dailyLogEntity.name = "DailyLog"
        dailyLogEntity.managedObjectClassName = NSStringFromClass(DailyLog.self)
        
        // Create attributes for DailyLog
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType
        idAttribute.isOptional = false
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false
        
        let stayedCleanAttribute = NSAttributeDescription()
        stayedCleanAttribute.name = "stayedClean"
        stayedCleanAttribute.attributeType = .booleanAttributeType
        stayedCleanAttribute.isOptional = false
        
        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true
        
        let userIdAttribute = NSAttributeDescription()
        userIdAttribute.name = "userId"
        userIdAttribute.attributeType = .stringAttributeType
        userIdAttribute.isOptional = false
        
        // Add attributes to entity
        dailyLogEntity.properties = [idAttribute, dateAttribute, stayedCleanAttribute, noteAttribute, userIdAttribute]
        
        // Add entity to model
        model.entities = [dailyLogEntity]
        
        return model
    }
}

// Define a DailyLog class for testing
@objc(DailyLog)
public class DailyLog: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var stayedClean: Bool
    @NSManaged public var note: String?
    @NSManaged public var userId: String?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID().uuidString
        date = Date()
    }
    
    // Add fetchRequest method
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyLog> {
        return NSFetchRequest<DailyLog>(entityName: "DailyLog")
    }
}

// Extension to make DailyLog conform to NSFetchRequestResult
extension DailyLog: NSFetchRequestResult {}

func testDailyLogAccess() {
    // This is just to test compilation
    let context = TestPersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
    do {
        let results = try context.fetch(fetchRequest)
        print("DailyLog is accessible, found \(results.count) logs")
    } catch {
        print("Error: \(error)")
    }
}

func testCreateAndSaveDailyLog() {
    // Get the context
    let context = TestPersistenceController.shared.container.viewContext
    
    // Create a new DailyLog
    let dailyLog = DailyLog(context: context)
    dailyLog.id = UUID().uuidString
    dailyLog.date = Date()
    dailyLog.stayedClean = true
    dailyLog.note = "Test note"
    dailyLog.userId = "test-user"
    
    // Save the context
    do {
        try context.save()
        print("DailyLog saved successfully with id: \(dailyLog.id ?? "unknown")")
    } catch {
        print("Error saving DailyLog: \(error)")
    }
    
    // Fetch the DailyLog
    let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", dailyLog.id!)
    
    do {
        let results = try context.fetch(fetchRequest)
        if let fetchedLog = results.first {
            print("DailyLog fetched successfully:")
            print("  ID: \(fetchedLog.id ?? "unknown")")
            print("  Date: \(fetchedLog.date?.description ?? "unknown")")
            print("  Stayed Clean: \(fetchedLog.stayedClean)")
            print("  Note: \(fetchedLog.note ?? "none")")
            print("  User ID: \(fetchedLog.userId ?? "unknown")")
        } else {
            print("DailyLog not found")
        }
    } catch {
        print("Error fetching DailyLog: \(error)")
    }
}

// Run the tests
print("Running basic DailyLog access test...")
testDailyLogAccess()

print("\nRunning create and save DailyLog test...")
testCreateAndSaveDailyLog()

print("\nAll Core Data tests completed.") 