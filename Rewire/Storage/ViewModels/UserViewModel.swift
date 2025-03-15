import Foundation
import Combine
import SwiftUI

class UserViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    @Published var dailyLogs: [DailyLog] = []
    @Published var todayLog: DailyLog?
    @Published var activeChallenges: [UserChallenge] = []
    @Published var recoveryProgress: UserRecoveryProgress?
    @Published var recoveryMilestones: [RecoveryMilestone] = []
    
    // Reference to storage manager
    private let storageManager = StorageManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to storage manager changes
        setupSubscriptions()
        
        // Load initial data
        loadUserData()
    }
    
    private func setupSubscriptions() {
        // Subscribe to user changes
        storageManager.$currentUser
            .sink { [weak self] user in
                self?.user = user
                self?.isLoggedIn = user != nil
                self?.loadUserData()
            }
            .store(in: &cancellables)
        
        // Subscribe to daily logs changes
        storageManager.$dailyLogs
            .sink { [weak self] logs in
                self?.dailyLogs = logs
                self?.updateTodayLog()
            }
            .store(in: &cancellables)
        
        // Subscribe to user challenges changes
        storageManager.$userChallenges
            .sink { [weak self] challenges in
                guard let userId = self?.user?.id else { return }
                self?.activeChallenges = challenges.filter { $0.userId == userId && $0.isActive }
            }
            .store(in: &cancellables)
        
        // Subscribe to recovery progress changes
        storageManager.$userRecoveryProgress
            .sink { [weak self] progress in
                self?.recoveryProgress = progress
            }
            .store(in: &cancellables)
        
        // Subscribe to recovery milestones changes
        storageManager.$recoveryMilestones
            .sink { [weak self] milestones in
                guard let addictionType = self?.user?.addiction.type else { return }
                self?.recoveryMilestones = milestones.filter { $0.addictionType == addictionType }
                    .sorted { $0.startDay < $1.startDay }
            }
            .store(in: &cancellables)
    }
    
    private func loadUserData() {
        guard let user = user else { return }
        
        // Load daily logs
        dailyLogs = storageManager.dailyLogs.filter { $0.userId == user.id }
            .sorted { $0.date > $1.date }
        
        // Update today's log
        updateTodayLog()
        
        // Load active challenges
        activeChallenges = storageManager.getActiveUserChallenges(for: user.id)
        
        // Load recovery progress
        recoveryProgress = storageManager.userRecoveryProgress
        
        // Load recovery milestones
        recoveryMilestones = storageManager.getMilestones(for: user.addiction.type)
    }
    
    private func updateTodayLog() {
        todayLog = storageManager.getDailyLog(for: Date())
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String, addiction: AddictionType, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) {
        let addictionInfo = Addiction(
            type: addiction,
            quitDate: quitDate,
            costPerDay: costPerDay,
            timeSpentPerDay: timeSpentPerDay
        )
        
        let newUser = User(
            name: name,
            email: email,
            addiction: addictionInfo
        )
        
        storageManager.saveUser(newUser)
        
        // Create recovery progress if quit date is set
        if let quitDate = quitDate {
            let progress = UserRecoveryProgress(
                userId: newUser.id,
                addictionType: addiction,
                quitDate: quitDate
            )
            storageManager.saveUserRecoveryProgress(progress)
        }
    }
    
    func updateUserProfile(name: String? = nil, email: String? = nil) {
        storageManager.updateUser(name: name, email: email)
    }
    
    func updateAddiction(type: AddictionType? = nil, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) {
        guard var user = user else { return }
        
        if let type = type { user.addiction.type = type }
        if let quitDate = quitDate { user.addiction.quitDate = quitDate }
        if let costPerDay = costPerDay { user.addiction.costPerDay = costPerDay }
        if let timeSpentPerDay = timeSpentPerDay { user.addiction.timeSpentPerDay = timeSpentPerDay }
        
        storageManager.updateUser(addiction: user.addiction)
        
        // Update recovery progress if quit date changed
        if quitDate != nil, let progress = recoveryProgress {
            var updatedProgress = progress
            updatedProgress.quitDate = quitDate!
            updatedProgress.currentDay = updatedProgress.calculateCurrentDay()
            storageManager.saveUserRecoveryProgress(updatedProgress)
        } else if quitDate != nil {
            // Create new recovery progress
            let progress = UserRecoveryProgress(
                userId: user.id,
                addictionType: user.addiction.type,
                quitDate: quitDate!
            )
            storageManager.saveUserRecoveryProgress(progress)
        }
    }
    
    func updateSettings(notificationsEnabled: Bool? = nil, dailyReminderTime: Date? = nil, darkModeEnabled: Bool? = nil, privacyMode: Bool? = nil) {
        guard var user = user else { return }
        
        if let notificationsEnabled = notificationsEnabled { user.settings.notificationsEnabled = notificationsEnabled }
        if let dailyReminderTime = dailyReminderTime { user.settings.dailyReminderTime = dailyReminderTime }
        if let darkModeEnabled = darkModeEnabled { user.settings.darkModeEnabled = darkModeEnabled }
        if let privacyMode = privacyMode { user.settings.privacyMode = privacyMode }
        
        storageManager.updateUser(settings: user.settings)
    }
    
    // MARK: - Daily Log Management
    
    func saveDailyLog(stayedClean: Bool, wellbeingRatings: WellbeingRatings, note: String? = nil) {
        guard let userId = user?.id else { return }
        
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
        guard var user = user else { return }
        
        if stayedClean {
            // Increment streak
            user.streakDays += 1
            user.totalCleanDays += 1
        } else {
            // Reset streak
            user.streakDays = 0
        }
        
        storageManager.saveUser(user)
    }
    
    // MARK: - Challenge Management
    
    func startChallenge(challenge: Challenge) {
        guard let userId = user?.id else { return }
        
        // Create task progress dictionary
        var taskProgress: [String: Bool] = [:]
        for task in challenge.tasks {
            taskProgress[task.id] = false
        }
        
        // Create user challenge
        let userChallenge = UserChallenge(
            userId: userId,
            challengeId: challenge.id,
            taskProgress: taskProgress
        )
        
        storageManager.saveUserChallenge(userChallenge)
    }
    
    func completeTask(challengeId: String, taskId: String) {
        guard let index = activeChallenges.firstIndex(where: { $0.challengeId == challengeId }) else { return }
        
        var challenge = activeChallenges[index]
        challenge.taskProgress[taskId] = true
        
        // Calculate progress
        let totalTasks = challenge.taskProgress.count
        let completedTasks = challenge.taskProgress.values.filter { $0 }.count
        challenge.progress = Double(completedTasks) / Double(totalTasks)
        
        // Check if all tasks are completed
        if completedTasks == totalTasks {
            challenge.isCompleted = true
            challenge.isActive = false
            challenge.endDate = Date()
        }
        
        storageManager.saveUserChallenge(challenge)
    }
    
    // MARK: - Recovery Management
    
    func updateRecoveryProgress() {
        storageManager.updateUserRecoveryProgress()
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
    
    func getMoneySaved() -> Double {
        guard let user = user, let costPerDay = user.addiction.costPerDay, let quitDate = user.addiction.quitDate else {
            return 0.0
        }
        
        let daysSinceQuitting = quitDate.daysBetween(date: Date())
        return Double(daysSinceQuitting) * costPerDay
    }
    
    func getTimeReclaimed() -> TimeInterval {
        guard let user = user, let timePerDay = user.addiction.timeSpentPerDay, let quitDate = user.addiction.quitDate else {
            return 0.0
        }
        
        let daysSinceQuitting = quitDate.daysBetween(date: Date())
        return Double(daysSinceQuitting) * timePerDay * 60 // Convert minutes to seconds
    }
} 