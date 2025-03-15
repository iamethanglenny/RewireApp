import Foundation
import CoreData
import Combine

class CoreDataManager {
    // Singleton instance
    static let shared = CoreDataManager()
    
    // Reference to the persistence controller
    private let persistenceController = PersistenceController.shared
    
    // Published properties for reactive UI updates
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton
    private init() {}
    
    // MARK: - DailyLog Management
    
    func saveDailyLog(_ log: DailyLog) {
        let context = persistenceController.container.viewContext
        
        // Check if the log already exists
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", log.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingLog = results.first {
                // Update existing log
                updateDailyLog(existingLog, with: log)
            } else {
                // Create new log
                let newLog = DailyLog(context: context)
                updateDailyLog(newLog, with: log)
            }
            
            try context.save()
        } catch {
            print("Error saving daily log: \(error)")
        }
    }
    
    private func updateDailyLog(_ managedLog: DailyLog, with log: DailyLog) {
        managedLog.id = log.id
        managedLog.userId = log.userId
        managedLog.date = log.date
        managedLog.stayedClean = log.stayedClean
        managedLog.note = log.note
        
        // Handle wellbeing ratings
        if let wellbeingRatings = managedLog.wellbeingRatings {
            wellbeingRatings.mood = Int16(log.wellbeingRatings.mood)
            wellbeingRatings.energy = Int16(log.wellbeingRatings.energy)
            wellbeingRatings.sleep = Int16(log.wellbeingRatings.sleep)
            wellbeingRatings.cravingIntensity = Int16(log.wellbeingRatings.cravingIntensity)
        } else {
            let newRatings = WellbeingRatings(context: managedLog.managedObjectContext!)
            newRatings.id = UUID().uuidString
            newRatings.mood = Int16(log.wellbeingRatings.mood)
            newRatings.energy = Int16(log.wellbeingRatings.energy)
            newRatings.sleep = Int16(log.wellbeingRatings.sleep)
            newRatings.cravingIntensity = Int16(log.wellbeingRatings.cravingIntensity)
            newRatings.dailyLog = managedLog
            managedLog.wellbeingRatings = newRatings
        }
        
        // Handle cravings
        // First, remove existing cravings
        if let existingCravings = managedLog.cravings as? Set<CravingRecord> {
            for craving in existingCravings {
                managedLog.removeFromCravings(craving)
                managedLog.managedObjectContext?.delete(craving)
            }
        }
        
        // Then add new cravings
        for craving in log.cravings {
            let newCraving = CravingRecord(context: managedLog.managedObjectContext!)
            newCraving.id = craving.id
            newCraving.timestamp = craving.timestamp
            newCraving.intensity = Int16(craving.intensity)
            newCraving.duration = craving.duration
            newCraving.trigger = craving.trigger
            newCraving.location = craving.location
            newCraving.overcame = craving.overcame
            newCraving.notes = craving.notes
            newCraving.dailyLog = managedLog
            managedLog.addToCravings(newCraving)
        }
    }
    
    func getDailyLog(for date: Date) -> DailyLog? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        
        // Create calendar components for the start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching daily log: \(error)")
            return nil
        }
    }
    
    func getDailyLogs(startDate: Date, endDate: Date) -> [DailyLog] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching daily logs: \(error)")
            return []
        }
    }
    
    // MARK: - Challenge Management
    
    func saveChallenge(_ challenge: Challenge) {
        let context = persistenceController.container.viewContext
        
        // Check if the challenge already exists
        let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", challenge.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingChallenge = results.first {
                // Update existing challenge
                updateChallenge(existingChallenge, with: challenge)
            } else {
                // Create new challenge
                let newChallenge = Challenge(context: context)
                updateChallenge(newChallenge, with: challenge)
            }
            
            try context.save()
        } catch {
            print("Error saving challenge: \(error)")
        }
    }
    
    private func updateChallenge(_ managedChallenge: Challenge, with challenge: Challenge) {
        managedChallenge.id = challenge.id
        managedChallenge.title = challenge.title
        managedChallenge.desc = challenge.description
        managedChallenge.difficulty = challenge.difficulty
        managedChallenge.daysToComplete = Int32(challenge.daysToComplete)
        managedChallenge.progress = challenge.progress
        
        // Handle tasks
        // First, remove existing tasks
        if let existingTasks = managedChallenge.tasks as? Set<ChallengeTask> {
            for task in existingTasks {
                managedChallenge.removeFromTasks(task)
                managedChallenge.managedObjectContext?.delete(task)
            }
        }
        
        // Then add new tasks
        for task in challenge.tasks {
            let newTask = ChallengeTask(context: managedChallenge.managedObjectContext!)
            newTask.id = task.id
            newTask.title = task.title
            newTask.desc = task.description
            newTask.isCompleted = task.isCompleted
            newTask.completionDate = task.completionDate
            newTask.challenge = managedChallenge
            managedChallenge.addToTasks(newTask)
        }
    }
    
    func getAllChallenges() -> [Challenge] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching challenges: \(error)")
            return []
        }
    }
    
    // MARK: - Migration
    
    func migrateFromFileStorage(storageManager: StorageManager) {
        // Migrate users
        if let user = storageManager.currentUser {
            saveUser(user)
        }
        
        // Migrate daily logs
        for log in storageManager.dailyLogs {
            saveDailyLog(log)
        }
        
        // Migrate challenges
        for challenge in storageManager.challenges {
            saveChallenge(challenge)
        }
        
        // Migrate user challenges
        for userChallenge in storageManager.userChallenges {
            saveUserChallenge(userChallenge)
        }
        
        // Migrate recovery milestones
        for milestone in storageManager.recoveryMilestones {
            saveRecoveryMilestone(milestone)
        }
        
        // Migrate user recovery progress
        if let progress = storageManager.userRecoveryProgress {
            saveUserRecoveryProgress(progress)
        }
        
        // Save all changes
        do {
            try persistenceController.container.viewContext.save()
            print("Migration completed successfully")
        } catch {
            print("Error during migration: \(error)")
        }
    }
    
    // Add other methods for User, UserChallenge, RecoveryMilestone, etc.
    
    // These are placeholders - you'll need to implement them based on your model
    func saveUser(_ user: User) {
        // Implementation
    }
    
    func saveUserChallenge(_ userChallenge: UserChallenge) {
        // Implementation
    }
    
    func saveRecoveryMilestone(_ milestone: RecoveryMilestone) {
        // Implementation
    }
    
    func saveUserRecoveryProgress(_ progress: UserRecoveryProgress) {
        // Implementation
    }
} 