import Foundation
import SwiftUI

class StatsViewModel: ObservableObject {
    private let analyticsService = AnalyticsService.shared
    private let dataManager = DataManager.shared
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var successRate: Double = 0
    @Published var vapeFreeCount: Int = 0
    @Published var totalDays: Int = 0
    @Published var moneySaved: Double = 0
    @Published var projectedYearlySavings: Double = 0
    @Published var correlations: [String: Double] = [:]
    @Published var dailyVapingCost: Double?
    
    init() {
        loadUserSettings()
        updateStreaks()
    }
    
    func updateStats(for timeframe: Timeframe) {
        updateStreaks()
        updateSuccessRate(for: timeframe)
        updateFinancialStats()
        updateCorrelations()
    }
    
    private func loadUserSettings() {
        if let settings = dataManager.getUserSettings() {
            dailyVapingCost = settings.dailyVapingCost
        }
    }
    
    private func updateStreaks() {
        currentStreak = analyticsService.getCurrentStreak()
        longestStreak = analyticsService.getLongestStreak()
    }
    
    private func updateSuccessRate(for timeframe: Timeframe) {
        let endDate = Date()
        let startDate: Date
        
        switch timeframe {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
            successRate = analyticsService.getWeeklySuccessRate()
        case .month:
            startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
            successRate = analyticsService.getMonthlySuccessRate()
        case .allTime:
            // Use all available data
            successRate = analyticsService.getOverallSuccessRate()
            let logs = dataManager.getAllDailyLogs()
            if let firstLog = logs.last {
                startDate = firstLog.date ?? endDate
            } else {
                startDate = endDate
            }
        }
        
        let logs = dataManager.getDailyLogs(from: startDate, to: endDate)
        vapeFreeCount = logs.filter { !$0.didVape }.count
        totalDays = logs.count
    }
    
    private func updateFinancialStats() {
        moneySaved = analyticsService.calculateMoneySaved()
        projectedYearlySavings = analyticsService.calculateProjectedYearlySavings()
    }
    
    private func updateCorrelations() {
        correlations = analyticsService.analyzeWellbeingCorrelations()
    }
} 