import Foundation
import CoreData

func testDailyLogAccess() {
    // This is just to test compilation
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
    do {
        let _ = try context.fetch(fetchRequest)
        print("DailyLog is accessible")
    } catch {
        print("Error: \(error)")
    }
} 