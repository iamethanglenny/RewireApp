import CoreData

struct PersistenceController {
    // Singleton instance
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create example data for previews
        let viewContext = controller.container.viewContext
        
        // Add 10 example DailyLog items
        for i in 0..<10 {
            let newDailyLog = DailyLog(context: viewContext)
            newDailyLog.id = UUID().uuidString
            newDailyLog.userId = "preview-user"
            newDailyLog.date = Date().addingTimeInterval(Double(i) * -86400) // Previous days
            newDailyLog.stayedClean = Bool.random()
            newDailyLog.note = "Example note for day \(i)"
        }
        
        do {
            try viewContext.save()
        } catch {
            // Handle error in preview provider
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // Initialize with optional in-memory store
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RewireModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Handle error in production code
                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Merge changes from parent contexts automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Uncomment to see SQL debug info
        // container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Helper Methods
    
    // Save context if there are changes
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Create a background context for performing operations off the main thread
    func backgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
} 