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
        
        // Create sample daily logs for the last 7 days
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let newLog = DailyLog(context: viewContext)
                newLog.date = date
                newLog.didVape = Bool.random()
                newLog.moodScore = Int16.random(in: 1...5)
                newLog.energyScore = Int16.random(in: 1...5)
                newLog.sleepScore = Int16.random(in: 1...5)
                newLog.cravingsScore = Int16.random(in: 1...5)
                newLog.notes = "Sample note for preview"
            }
        }
        
        // Create user settings
        let settings = UserSettings(context: viewContext)
        settings.dailyVapingCost = 10.0
        settings.quitDate = calendar.date(byAdding: .day, value: -30, to: today)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // Initialize with optional in-memory store
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Rewire")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Merge changes from parent contexts automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Observe Core Data remote change notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(managedObjectContextObjectsDidChange),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: container.viewContext)
    }
    
    // Handle Core Data change notifications
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        // Post a notification that our data has changed
        NotificationCenter.default.post(name: .dailyLogDataDidChange, object: nil)
    }
}

// Notification name for data changes
extension NSNotification.Name {
    static let dailyLogDataDidChange = NSNotification.Name("dailyLogDataDidChange")
} 