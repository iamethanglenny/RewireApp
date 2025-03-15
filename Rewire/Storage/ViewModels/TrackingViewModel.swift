import Foundation
import Combine
import SwiftData

enum TimePeriod {
    case week
    case month
    case lifetime
}

class TrackingViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var dailyLogs: [DailyLog] = []
    @Published var todayLog: DailyLog?
    @Published var recentCravings: [CravingRecord] = []
    @Published var wellbeingTrends: [String: [Int]] = [:]
    
    // Reference to data manager
    private let dataManager = SwiftDataManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to data manager changes
        setupSubscriptions()
        
        // Load initial data
        loadData()
    }
    
    private func setupSubscriptions() {
        // Subscribe to daily logs changes
        dataManager.$dailyLogs
            .sink { [weak self] logs in
                guard let userId = self?.dataManager.currentUser?.id else { return }
                self?.dailyLogs = logs.filter { $0.user?.id == userId }
                    .sorted { $0.date > $1.date }
                self?.updateTodayLog()
                self?.updateRecentCravings()
                self?.calculateWellbeingTrends()
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        guard let userId = dataManager.currentUser?.id else { return }
        
        // Load daily logs
        dailyLogs = dataManager.dailyLogs.filter { $0.user?.id == userId }
            .sorted { $0.date > $1.date }
        
        // Update today's log
        updateTodayLog()
    }
    
    private func updateTodayLog() {
        todayLog = dataManager.getDailyLog(for: Date())
    }
    
    private func updateRecentCravings() {
        // Get cravings from the last 7 days
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentLogs = dailyLogs.filter { $0.date >= sevenDaysAgo }
        recentCravings = recentLogs.flatMap { $0.cravings }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    private func calculateWellbeingTrends() {
        // Get logs from the last 30 days
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let recentLogs = dailyLogs.filter { $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date } // Sort by date (oldest first)
        
        // Initialize trends
        wellbeingTrends = [
            "mood": [],
            "energy": [],
            "sleep": [],
            "cravingIntensity": []
        ]
        
        // Populate trends
        for log in recentLogs {
            wellbeingTrends["mood"]?.append(log.wellbeingRatings.mood)
            wellbeingTrends["energy"]?.append(log.wellbeingRatings.energy)
            wellbeingTrends["sleep"]?.append(log.wellbeingRatings.sleep)
            wellbeingTrends["cravingIntensity"]?.append(log.wellbeingRatings.cravingIntensity)
        }
    }
    
    // MARK: - Daily Log Management
    
    func saveDailyLog(stayedClean: Bool, wellbeingRatings: WellbeingRatings, note: String? = nil) {
        _ = dataManager.saveDailyLog(
            stayedClean: stayedClean,
            wellbeingRatings: wellbeingRatings,
            note: note
        )
        
        // Update today's log
        updateTodayLog()
    }
    
    func addCravingRecord(intensity: Int, duration: TimeInterval, trigger: String? = nil, location: String? = nil, overcame: Bool = true, notes: String? = nil) {
        dataManager.addCravingRecord(
            intensity: intensity,
            duration: duration,
            trigger: trigger,
            location: location,
            overcame: overcame,
            notes: notes
        )
        
        // Update today's log
        updateTodayLog()
    }
    
    // MARK: - Statistics
    
    func getCleanDaysPercentage(for period: TimePeriod) -> Double {
        guard !dailyLogs.isEmpty else { return 0.0 }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        guard !logs.isEmpty else { return 0.0 }
        
        let cleanDays = logs.filter { $0.stayedClean }.count
        return Double(cleanDays) / Double(logs.count)
    }
    
    func getAverageCravingIntensity(for period: TimePeriod) -> Double {
        guard !dailyLogs.isEmpty else { return 0.0 }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        let allCravings = logs.flatMap { $0.cravings ?? [] }
        guard !allCravings.isEmpty else { return 0.0 }
        
        let totalIntensity = allCravings.reduce(0) { $0 + $1.intensity }
        return Double(totalIntensity) / Double(allCravings.count)
    }
    
    func getAverageCravingDuration(for period: TimePeriod) -> TimeInterval {
        guard !dailyLogs.isEmpty else { return 0.0 }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        let allCravings = logs.flatMap { $0.cravings ?? [] }
        guard !allCravings.isEmpty else { return 0.0 }
        
        let totalDuration = allCravings.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(allCravings.count)
    }
    
    func getCravingsByTrigger(for period: TimePeriod) -> [String: Int] {
        guard !dailyLogs.isEmpty else { return [:] }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        let allCravings = logs.flatMap { $0.cravings ?? [] }
        
        var triggerCounts: [String: Int] = [:]
        
        for craving in allCravings {
            if let trigger = craving.trigger {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        
        return triggerCounts
    }
    
    func getCravingsByLocation(for period: TimePeriod) -> [String: Int] {
        guard !dailyLogs.isEmpty else { return [:] }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        let allCravings = logs.flatMap { $0.cravings ?? [] }
        
        var locationCounts: [String: Int] = [:]
        
        for craving in allCravings {
            if let location = craving.location {
                locationCounts[location, default: 0] += 1
            }
        }
        
        return locationCounts
    }
    
    func getAverageWellbeingRatings(for period: TimePeriod) -> (mood: Double, energy: Double, sleep: Double, cravingIntensity: Double) {
        guard !dailyLogs.isEmpty else { return (0, 0, 0, 0) }
        
        var logs: [DailyLog] = []
        let today = Date()
        
        switch period {
        case .week:
            logs = dailyLogs.filter { $0.date >= today.startOfWeek && $0.date <= today }
        case .month:
            logs = dailyLogs.filter { $0.date >= today.startOfMonth && $0.date <= today }
        case .lifetime:
            logs = dailyLogs
        }
        
        let logsWithRatings = logs.filter { $0.wellbeingRatings != nil }
        guard !logsWithRatings.isEmpty else { return (0, 0, 0, 0) }
        
        let count = Double(logsWithRatings.count)
        
        let totalMood = logsWithRatings.reduce(0) { $0 + ($1.wellbeingRatings?.mood ?? 0) }
        let totalEnergy = logsWithRatings.reduce(0) { $0 + ($1.wellbeingRatings?.energy ?? 0) }
        let totalSleep = logsWithRatings.reduce(0) { $0 + ($1.wellbeingRatings?.sleep ?? 0) }
        let totalCravingIntensity = logsWithRatings.reduce(0) { $0 + ($1.wellbeingRatings?.cravingIntensity ?? 0) }
        
        return (
            mood: Double(totalMood) / count,
            energy: Double(totalEnergy) / count,
            sleep: Double(totalSleep) / count,
            cravingIntensity: Double(totalCravingIntensity) / count
        )
    }
} 