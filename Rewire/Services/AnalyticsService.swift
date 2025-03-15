import Foundation
import CoreData
import SwiftUI

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private let dataManager = DataManager.shared
    
    // MARK: - Financial Analytics
    
    /// Calculate money saved by not vaping
    func calculateMoneySaved() -> Double {
        guard let settings = dataManager.getUserSettings(),
              let quitDate = settings.quitDate else {
            return 0
        }
        
        let dailyCost = settings.dailyVapingCost
        let logs = dataManager.getDailyLogs(from: quitDate, to: Date())
        
        // Sum up the days where user didn't vape
        let vapeFreeCount = logs.filter { !$0.didVape }.count
        
        return Double(vapeFreeCount) * dailyCost
    }
    
    /// Calculate projected yearly savings
    func calculateProjectedYearlySavings() -> Double {
        guard let settings = dataManager.getUserSettings() else {
            return 0
        }
        
        let dailyCost = settings.dailyVapingCost
        let successRate = getOverallSuccessRate()
        
        // Project based on current success rate
        let projectedVapeFreeDays = 365 * (successRate / 100)
        return projectedVapeFreeDays * dailyCost
    }
    
    // MARK: - Success Metrics
    
    /// Get overall success rate since tracking began
    func getOverallSuccessRate() -> Double {
        let logs = dataManager.getAllDailyLogs()
        
        guard !logs.isEmpty else {
            return 0
        }
        
        let vapeFreeCount = logs.filter { !$0.didVape }.count
        return Double(vapeFreeCount) / Double(logs.count) * 100
    }
    
    /// Get success rate for the last week
    func getWeeklySuccessRate() -> Double {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        
        return dataManager.getSuccessRate(from: startDate, to: endDate)
    }
    
    /// Get success rate for the last month
    func getMonthlySuccessRate() -> Double {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
        
        return dataManager.getSuccessRate(from: startDate, to: endDate)
    }
    
    // MARK: - Streak Analytics
    
    /// Get current vape-free streak
    func getCurrentStreak() -> Int {
        return dataManager.getCurrentVapeFreeStreak()
    }
    
    /// Get longest vape-free streak
    func getLongestStreak() -> Int {
        return dataManager.getLongestVapeFreeStreak()
    }
    
    // MARK: - Correlation Analysis
    
    /// Analyze correlation between wellbeing scores and vaping behavior
    func analyzeWellbeingCorrelations() -> [String: Double] {
        let logs = dataManager.getAllDailyLogs()
        
        guard logs.count > 5 else {
            return [:]
        }
        
        let vapeDays = logs.filter { $0.didVape }
        let noVapeDays = logs.filter { !$0.didVape }
        
        guard !vapeDays.isEmpty && !noVapeDays.isEmpty else {
            return [:]
        }
        
        // Calculate average scores for days with and without vaping
        let vapeAvgMood = vapeDays.reduce(0) { $0 + Double($1.moodScore) } / Double(vapeDays.count)
        let noVapeAvgMood = noVapeDays.reduce(0) { $0 + Double($1.moodScore) } / Double(noVapeDays.count)
        
        let vapeAvgEnergy = vapeDays.reduce(0) { $0 + Double($1.energyScore) } / Double(vapeDays.count)
        let noVapeAvgEnergy = noVapeDays.reduce(0) { $0 + Double($1.energyScore) } / Double(noVapeDays.count)
        
        let vapeAvgSleep = vapeDays.reduce(0) { $0 + Double($1.sleepScore) } / Double(vapeDays.count)
        let noVapeAvgSleep = noVapeDays.reduce(0) { $0 + Double($1.sleepScore) } / Double(noVapeDays.count)
        
        let vapeAvgCravings = vapeDays.reduce(0) { $0 + Double($1.cravingsScore) } / Double(vapeDays.count)
        let noVapeAvgCravings = noVapeDays.reduce(0) { $0 + Double($1.cravingsScore) } / Double(noVapeDays.count)
        
        // Calculate differences (positive means better when not vaping)
        return [
            "mood": noVapeAvgMood - vapeAvgMood,
            "energy": noVapeAvgEnergy - vapeAvgEnergy,
            "sleep": noVapeAvgSleep - vapeAvgSleep,
            "cravings": noVapeAvgCravings - vapeAvgCravings
        ]
    }
    
    // MARK: - Trend Analysis
    
    /// Get trend data for a specific wellbeing metric over time
    func getTrendData(for metric: WellbeingMetric, days: Int = 30) -> [(date: Date, value: Double)] {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -(days-1), to: endDate)!
        
        let logs = dataManager.getDailyLogs(from: startDate, to: endDate)
        
        // Create a dictionary with dates as keys
        var dataByDate: [Date: Double] = [:]
        
        // Fill in the data we have
        for log in logs {
            guard let date = log.date else { continue }
            
            let value: Double
            switch metric {
            case .mood:
                value = Double(log.moodScore)
            case .energy:
                value = Double(log.energyScore)
            case .sleep:
                value = Double(log.sleepScore)
            case .cravings:
                value = Double(log.cravingsScore)
            }
            
            dataByDate[date.startOfDay] = value
        }
        
        // Create array of dates for the requested period
        var result: [(date: Date, value: Double)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let normalizedDate = currentDate.startOfDay
            let value = dataByDate[normalizedDate] ?? 0
            result.append((date: normalizedDate, value: value))
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    /// Get calendar data for month view
    func getCalendarData(for month: Date) -> [Date: Bool] {
        let calendar = Calendar.current
        
        // Get start and end of month
        let components = calendar.dateComponents([.year, .month], from: month)
        let startOfMonth = calendar.date(from: components)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
        
        // Get logs for the month
        let logs = dataManager.getDailyLogs(from: startOfMonth, to: endOfMonth)
        
        // Create dictionary mapping dates to vaping status
        var result: [Date: Bool] = [:]
        
        for log in logs {
            if let date = log.date {
                result[date.startOfDay] = log.didVape
            }
        }
        
        return result
    }
}

enum WellbeingMetric {
    case mood, energy, sleep, cravings
} 