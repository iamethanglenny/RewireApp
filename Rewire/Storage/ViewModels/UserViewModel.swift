import Foundation
import Combine
import SwiftUI
import SwiftData

class UserViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    @Published var dailyLogs: [DailyLog] = []
    @Published var todayLog: DailyLog?
    @Published var activeChallenges: [UserChallenge] = []
    @Published var recoveryProgress: UserRecoveryProgress?
    @Published var recoveryMilestones: [RecoveryMilestone] = []
    
    // Reference to data manager
    private let dataManager = SwiftDataManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to data manager changes
        setupSubscriptions()
        
        // Load initial data
        loadUserData()
    }
    
    private func setupSubscriptions() {
        // Subscribe to user changes
        dataManager.$currentUser
            .sink { [weak self] user in
                self?.user = user
                self?.isLoggedIn = user != nil
                self?.loadUserData()
            }
            .store(in: &cancellables)
        
        // Subscribe to daily logs changes
        dataManager.$dailyLogs
            .sink { [weak self] logs in
                guard let userId = self?.user?.id else { return }
                self?.dailyLogs = logs.filter { $0.user?.id == userId }
                    .sorted { $0.date > $1.date }
                self?.updateTodayLog()
            }
            .store(in: &cancellables)
        
        // Subscribe to user challenges changes
        dataManager.$userChallenges
            .sink { [weak self] challenges in
                guard let userId = self?.user?.id else { return }
                self?.activeChallenges = challenges.filter { $0.user?.id == userId && $0.isActive }
            }
            .store(in: &cancellables)
        
        // Subscribe to recovery progress changes
        dataManager.$userRecoveryProgress
            .sink { [weak self] progress in
                self?.recoveryProgress = progress
            }
            .store(in: &cancellables)
        
        // Subscribe to recovery milestones changes
        dataManager.$recoveryMilestones
            .sink { [weak self] milestones in
                guard let addictionType = self?.user?.addiction else { return }
                self?.recoveryMilestones = milestones.filter { $0.addictionType == addictionType }
                    .sorted { $0.startDay < $1.startDay }
            }
            .store(in: &cancellables)
    }
    
    private func loadUserData() {
        guard let user = user else { return }
        
        // Load daily logs
        dailyLogs = dataManager.dailyLogs.filter { $0.user?.id == user.id }
            .sorted { $0.date > $1.date }
        
        // Update today's log
        updateTodayLog()
        
        // Load active challenges
        activeChallenges = dataManager.userChallenges.filter { $0.user?.id == user.id && $0.isActive }
        
        // Load recovery progress
        recoveryProgress = user.recoveryProgress
        
        // Load recovery milestones
        recoveryMilestones = dataManager.recoveryMilestones.filter { $0.addictionType == user.addiction }
            .sorted { $0.startDay < $1.startDay }
    }
    
    private func updateTodayLog() {
        todayLog = dataManager.getDailyLog(for: Date())
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String, addiction: AddictionType, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) {
        let newUser = dataManager.createUser(
            name: name,
            email: email,
            addiction: addiction,
            quitDate: quitDate,
            costPerDay: costPerDay,
            timeSpentPerDay: timeSpentPerDay
        )
        
        user = newUser
        isLoggedIn = true
    }
    
    func updateUser(name: String? = nil, email: String? = nil, addiction: AddictionType? = nil, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) {
        guard var updatedUser = user else { return }
        
        // Update user properties if provided
        if let name = name {
            updatedUser.name = name
        }
        
        if let email = email {
            updatedUser.email = email
        }
        
        if let addiction = addiction {
            updatedUser.addiction = addiction
        }
        
        if let quitDate = quitDate {
            updatedUser.quitDate = quitDate
            
            // Update or create recovery progress
            if updatedUser.recoveryProgress == nil {
                _ = dataManager.createUserRecoveryProgress(user: updatedUser, quitDate: quitDate)
            } else {
                updatedUser.recoveryProgress?.quitDate = quitDate
                updatedUser.recoveryProgress?.currentDay = updatedUser.recoveryProgress?.calculateCurrentDay() ?? 1
            }
        }
        
        if let costPerDay = costPerDay {
            updatedUser.costPerDay = costPerDay
        }
        
        if let timeSpentPerDay = timeSpentPerDay {
            updatedUser.timeSpentPerDay = timeSpentPerDay
        }
        
        // Update timestamp
        updatedUser.updatedAt = Date()
        
        // Save changes
        dataManager.updateUser(updatedUser)
        user = updatedUser
    }
    
    func logout() {
        // Just clear the current user reference
        user = nil
        isLoggedIn = false
    }
    
    func deleteAccount() {
        guard let user = user else { return }
        
        // Delete user from storage
        dataManager.deleteUser(user)
        
        // Clear local references
        self.user = nil
        isLoggedIn = false
    }
    
    // MARK: - Recovery Progress
    
    func updateRecoveryProgress() {
        dataManager.updateRecoveryProgress()
    }
    
    func completeRecoveryMilestone(milestoneId: String) -> Bool {
        return dataManager.completeRecoveryMilestone(milestoneId: milestoneId)
    }
    
    // MARK: - Statistics
    
    func getCleanDaysCount() -> Int {
        guard let quitDate = user?.quitDate else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(0, components.day ?? 0)
    }
    
    func getStreakDays() -> Int {
        var streakDays = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check each day going backwards
        while true {
            // Get log for the current day
            if let log = dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                // If stayed clean, increment streak
                if log.stayedClean {
                    streakDays += 1
                } else {
                    // Break streak
                    break
                }
            } else if let quitDate = user?.quitDate, currentDate >= calendar.startOfDay(for: quitDate) {
                // No log but after quit date, assume clean
                streakDays += 1
            } else {
                // No log and before quit date, end streak
                break
            }
            
            // Move to previous day
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streakDays
    }
    
    func getMoneySaved() -> Double {
        guard let costPerDay = user?.costPerDay, let quitDate = user?.quitDate else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        let days = max(0, components.day ?? 0)
        
        return Double(days) * costPerDay
    }
    
    func getTimeSaved() -> TimeInterval {
        guard let timePerDay = user?.timeSpentPerDay, let quitDate = user?.quitDate else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        let days = max(0, components.day ?? 0)
        
        // Convert minutes to seconds
        return Double(days) * timePerDay * 60
    }
} 