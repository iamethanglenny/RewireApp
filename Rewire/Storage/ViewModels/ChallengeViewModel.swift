import Foundation
import Combine
import SwiftData

class ChallengeViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var challenges: [Challenge] = []
    @Published var userChallenges: [UserChallenge] = []
    @Published var activeChallenges: [UserChallenge] = []
    @Published var completedChallenges: [UserChallenge] = []
    
    // Reference to data manager
    private let dataManager = SwiftDataManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to data manager changes
        setupSubscriptions()
        
        // Load initial data
        loadChallenges()
    }
    
    private func setupSubscriptions() {
        // Subscribe to challenges changes
        dataManager.$challenges
            .sink { [weak self] challenges in
                self?.challenges = challenges
            }
            .store(in: &cancellables)
        
        // Subscribe to user challenges changes
        dataManager.$userChallenges
            .sink { [weak self] userChallenges in
                self?.userChallenges = userChallenges
                self?.updateChallengeCategories()
            }
            .store(in: &cancellables)
        
        // Subscribe to user changes
        dataManager.$currentUser
            .sink { [weak self] _ in
                self?.updateChallengeCategories()
            }
            .store(in: &cancellables)
    }
    
    private func loadChallenges() {
        challenges = dataManager.challenges
        userChallenges = dataManager.userChallenges
        updateChallengeCategories()
    }
    
    private func updateChallengeCategories() {
        guard let userId = dataManager.currentUser?.id else {
            activeChallenges = []
            completedChallenges = []
            return
        }
        
        // Filter user challenges
        activeChallenges = userChallenges.filter { $0.user?.id == userId && $0.isActive }
        completedChallenges = userChallenges.filter { $0.user?.id == userId && $0.isCompleted }
    }
    
    // MARK: - Challenge Management
    
    func getAvailableChallenges() -> [Challenge] {
        guard let userId = dataManager.currentUser?.id else { return [] }
        
        // Get IDs of challenges the user has already started or completed
        let userChallengeIds = userChallenges
            .filter { $0.user?.id == userId }
            .compactMap { $0.challenge?.id }
        
        // Return challenges that the user hasn't started yet
        return challenges.filter { !userChallengeIds.contains($0.id) }
    }
    
    func startChallenge(challengeId: String) {
        _ = dataManager.startChallenge(challengeId: challengeId)
    }
    
    func completeTask(challengeId: String, taskId: String) {
        _ = dataManager.completeTask(challengeId: challengeId, taskId: taskId)
    }
    
    func getChallengeDetails(for userChallenge: UserChallenge) -> Challenge? {
        return userChallenge.challenge
    }
    
    func getTasksForChallenge(userChallenge: UserChallenge) -> [ChallengeTask] {
        return userChallenge.challenge?.tasks ?? []
    }
    
    func isTaskCompleted(userChallenge: UserChallenge, taskId: String) -> Bool {
        guard let task = userChallenge.challenge?.tasks?.first(where: { $0.id == taskId }) else {
            return false
        }
        
        return userChallenge.isTaskCompleted(task: task)
    }
    
    // MARK: - Challenge Creation (Admin)
    
    func createChallenge(title: String, challengeDescription: String, difficulty: String, daysToComplete: Int, tasks: [(title: String, description: String)]) {
        // Create challenge tasks
        var challengeTasks: [ChallengeTask] = []
        
        for task in tasks {
            let newTask = ChallengeTask(
                title: task.title,
                taskDescription: task.description
            )
            challengeTasks.append(newTask)
        }
        
        // Create and save the challenge
        _ = dataManager.createChallenge(
            title: title,
            challengeDescription: challengeDescription,
            difficulty: difficulty,
            daysToComplete: daysToComplete,
            tasks: challengeTasks
        )
    }
} 