import Foundation
import Combine

class TrackingViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var dailyLogs: [DailyLog] = []
    @Published var todayLog: DailyLog?
    @Published var recentCravings: [CravingRecord] = []
    @Published var wellbeingTrends: [String: [Int]] = [:]
    
    // Reference to storage manager
    private let storageManager = StorageManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to storage manager changes
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to daily logs changes
        storageManager.$dailyLogs
            .sink { [weak self] logs in
                guard let userId = self?.storageManager.currentUser?.id else { return }
                
                // Filter logs for current user and sort by date (newest first)
                let userLogs = logs.filter { $0.userId == userId }
                    .sorted { $0.date > $1.date }
                
                self?.dailyLogs = userLogs
                self?.updateTodayLog()
                self?.updateRecentCravings()
                self?.calculateWellbeingTrends()
            }
            .store(in: &cancellables)
    }
    
    private func updateTodayLog() {
        todayLog = storageManager.getDailyLog(for: Date())
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
        guard let userId = storageManager.currentUser?.id else { return }
        
        if var log = todayLog {
            // Update existing log
            log.stayedClean = stayedClean
            log.wellbeingRatings = wellbeingRatings
            log.note = note
            
            storageManager.saveDailyLog(log)
        } else {
            // Create new log
            let newLog = DailyLog(
                userId: userId,
                stayedClean: stayedClean,
                wellbeingRatings: wellbeingRatings,
                note: note
            )
            
            storageManager.saveDailyLog(newLog)
        }
        
        // Update streak if needed
        updateStreakIfNeeded(stayedClean: stayedClean)
    }
    
    func addCravingRecord(intensity: Int, duration: TimeInterval, trigger: String? = nil, location: String? = nil, overcame: Bool = true, notes: String? = nil) {
        let craving = CravingRecord(
            intensity: intensity,
            duration: duration,
            trigger: trigger,
            location: location,
            overcame: overcame,
            notes: notes
        )
        
        storageManager.addCravingRecord(craving, to: Date())
    }
    
    private func updateStreakIfNeeded(stayedClean: Bool) {
        guard let user = storageManager.currentUser else { return }
        
        if stayedClean {
            // Increment streak
            storageManager.updateUser(streakDays: user.streakDays + 1, totalCleanDays: user.totalCleanDays + 1)
        } else {
            // Reset streak
            storageManager.updateUser(streakDays: 0)
        }
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
        
        let allCravings = logs.flatMap { $0.cravings }
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
        
        let allCravings = logs.flatMap { $0.cravings }
        guard !allCravings.isEmpty else { return 0.0 }
        
        let totalDuration = allCravings.reduce(0.0) { $0 + $1.duration }
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
        
        let allCravings = logs.flatMap { $0.cravings }
        
        var triggerCounts: [String: Int] = [:]
        
        for craving in allCravings {
            let trigger = craving.trigger ?? "Unknown"
            triggerCounts[trigger, default: 0] += 1
        }
        
        return triggerCounts
    }
    
    func getCravingsByTime(for period: TimePeriod) -> [Int: Int] {
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
        
        let allCravings = logs.flatMap { $0.cravings }
        
        var hourCounts: [Int: Int] = [:]
        
        for craving in allCravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            hourCounts[hour, default: 0] += 1
        }
        
        return hourCounts
    }
} 