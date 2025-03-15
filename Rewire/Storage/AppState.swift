import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    // Singleton instance
    static let shared = AppState()
    
    // View models
    let userViewModel = UserViewModel()
    let challengeViewModel = ChallengeViewModel()
    let trackingViewModel = TrackingViewModel()
    
    // App state
    @Published var isOnboarding: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var selectedTab: Int = 0
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton
    private init() {
        // Check if user exists
        checkUserStatus()
        
        // Subscribe to user login status
        userViewModel.$isLoggedIn
            .sink { [weak self] isLoggedIn in
                self?.isLoggedIn = isLoggedIn
                self?.isOnboarding = !isLoggedIn
            }
            .store(in: &cancellables)
    }
    
    private func checkUserStatus() {
        // Check if user exists in storage
        isLoggedIn = StorageManager.shared.currentUser != nil
        isOnboarding = !isLoggedIn
    }
    
    // MARK: - App Navigation
    
    func navigateToHome() {
        selectedTab = 0
    }
    
    func navigateToRewiring() {
        selectedTab = 1
    }
    
    func navigateToProfile() {
        selectedTab = 2
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding(name: String, email: String, addiction: AddictionType, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) {
        // Create user
        userViewModel.createUser(
            name: name,
            email: email,
            addiction: addiction,
            quitDate: quitDate,
            costPerDay: costPerDay,
            timeSpentPerDay: timeSpentPerDay
        )
        
        // Set onboarding as complete
        isOnboarding = false
    }
    
    // MARK: - App Actions
    
    func logDailyCheck(stayedClean: Bool, wellbeingRatings: WellbeingRatings, note: String? = nil) {
        trackingViewModel.saveDailyLog(
            stayedClean: stayedClean,
            wellbeingRatings: wellbeingRatings,
            note: note
        )
    }
    
    func logCraving(intensity: Int, duration: TimeInterval, trigger: String? = nil, location: String? = nil, overcame: Bool = true, notes: String? = nil) {
        trackingViewModel.addCravingRecord(
            intensity: intensity,
            duration: duration,
            trigger: trigger,
            location: location,
            overcame: overcame,
            notes: notes
        )
    }
    
    func startChallenge(challengeId: String) {
        challengeViewModel.startChallenge(challengeId: challengeId)
    }
    
    func completeTask(challengeId: String, taskId: String) {
        challengeViewModel.completeTask(challengeId: challengeId, taskId: taskId)
    }
    
    func updateRecoveryProgress() {
        userViewModel.updateRecoveryProgress()
    }
    
    // MARK: - Statistics
    
    func getDaysSinceQuitting() -> Int? {
        guard let user = userViewModel.user,
              let quitDate = user.addiction.quitDate else {
            return nil
        }
        
        return quitDate.daysBetween(date: Date())
    }
    
    func getMoneySaved() -> Double {
        return userViewModel.getMoneySaved()
    }
    
    func getTimeReclaimed() -> TimeInterval {
        return userViewModel.getTimeReclaimed()
    }
    
    func getCleanDaysPercentage(for period: TimePeriod) -> Double {
        return trackingViewModel.getCleanDaysPercentage(for: period)
    }
    
    func getAverageCravingIntensity(for period: TimePeriod) -> Double {
        return trackingViewModel.getAverageCravingIntensity(for: period)
    }
    
    func getAverageCravingDuration(for period: TimePeriod) -> TimeInterval {
        return trackingViewModel.getAverageCravingDuration(for: period)
    }
} 