import CoreData
import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // MARK: - DailyLog CRUD Operations
    
    /// Save a new daily log entry or update existing one for the given date
    func saveDailyLog(date: Date = Date(), didVape: Bool, moodScore: Int, energyScore: Int, sleepScore: Int, cravingsScore: Int, notes: String?) -> Bool {
        // Normalize date to remove time component
        let normalizedDate = date.startOfDay
        
        // Check if a log already exists for this date
        if let existingLog = getDailyLog(for: normalizedDate) {
            // Update existing log
            existingLog.didVape = didVape
            existingLog.moodScore = Int16(moodScore)
            existingLog.energyScore = Int16(energyScore)
            existingLog.sleepScore = Int16(sleepScore)
            existingLog.cravingsScore = Int16(cravingsScore)
            existingLog.notes = notes
        } else {
            // Create new log
            let newLog = DailyLog(context: viewContext)
            newLog.date = normalizedDate
            newLog.didVape = didVape
            newLog.moodScore = Int16(moodScore)
            newLog.energyScore = Int16(energyScore)
            newLog.sleepScore = Int16(sleepScore)
            newLog.cravingsScore = Int16(cravingsScore)
            newLog.notes = notes
        }
        
        // Save changes
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error saving daily log: \(error)")
            return false
        }
    }
    
    /// Get daily log for a specific date
    func getDailyLog(for date: Date) -> DailyLog? {
        let normalizedDate = date.startOfDay
        
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", normalizedDate as NSDate)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching daily log: \(error)")
            return nil
        }
    }
    
    /// Get all daily logs within a date range
    func getDailyLogs(from startDate: Date, to endDate: Date) -> [DailyLog] {
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                            startDate.startOfDay as NSDate, 
                                            endDate.endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching daily logs: \(error)")
            return []
        }
    }
    
    /// Get all daily logs
    func getAllDailyLogs() -> [DailyLog] {
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching all daily logs: \(error)")
            return []
        }
    }
    
    /// Delete a daily log
    func deleteDailyLog(_ dailyLog: DailyLog) -> Bool {
        viewContext.delete(dailyLog)
        
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error deleting daily log: \(error)")
            return false
        }
    }
    
    // MARK: - User Settings
    
    /// Save or update user settings
    func saveUserSettings(dailyVapingCost: Double, quitDate: Date?) -> Bool {
        let settings = getUserSettings() ?? UserSettings(context: viewContext)
        settings.dailyVapingCost = dailyVapingCost
        settings.quitDate = quitDate
        
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error saving user settings: \(error)")
            return false
        }
    }
    
    /// Get user settings
    func getUserSettings() -> UserSettings? {
        let fetchRequest: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching user settings: \(error)")
            return nil
        }
    }
    
    // MARK: - Streak Calculations
    
    /// Calculate current streak of consecutive vape-free days
    func getCurrentVapeFreeStreak() -> Int {
        let today = Date()
        var currentStreak = 0
        var currentDate = today
        
        while true {
            guard let log = getDailyLog(for: currentDate) else {
                break
            }
            
            if log.didVape {
                break
            }
            
            currentStreak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
        }
        
        return currentStreak
    }
    
    /// Calculate longest streak of consecutive vape-free days
    func getLongestVapeFreeStreak() -> Int {
        let logs = getAllDailyLogs().sorted(by: { $0.date! < $1.date! })
        var longestStreak = 0
        var currentStreak = 0
        
        for log in logs {
            if !log.didVape {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return longestStreak
    }
    
    // MARK: - Average Calculations
    
    /// Calculate average scores for a specific time period
    func getAverageScores(from startDate: Date, to endDate: Date) -> (mood: Double, energy: Double, sleep: Double, cravings: Double) {
        let logs = getDailyLogs(from: startDate, to: endDate)
        
        guard !logs.isEmpty else {
            return (0, 0, 0, 0)
        }
        
        let moodSum = logs.reduce(0) { $0 + Double($1.moodScore) }
        let energySum = logs.reduce(0) { $0 + Double($1.energyScore) }
        let sleepSum = logs.reduce(0) { $0 + Double($1.sleepScore) }
        let cravingsSum = logs.reduce(0) { $0 + Double($1.cravingsScore) }
        
        let count = Double(logs.count)
        
        return (
            mood: moodSum / count,
            energy: energySum / count,
            sleep: sleepSum / count,
            cravings: cravingsSum / count
        )
    }
    
    /// Calculate success rate (percentage of vape-free days)
    func getSuccessRate(from startDate: Date, to endDate: Date) -> Double {
        let logs = getDailyLogs(from: startDate, to: endDate)
        
        guard !logs.isEmpty else {
            return 0
        }
        
        let vapeFreeCount = logs.filter { !$0.didVape }.count
        return Double(vapeFreeCount) / Double(logs.count) * 100
    }
} 