import Foundation
import Combine

class ChallengeViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var allChallenges: [Challenge] = []
    @Published var userChallenges: [UserChallenge] = []
    @Published var activeChallenges: [UserChallenge] = []
    @Published var completedChallenges: [UserChallenge] = []
    
    // Reference to storage manager
    private let storageManager = StorageManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to storage manager changes
        setupSubscriptions()
        
        // Create default challenges if none exist
        if storageManager.challenges.isEmpty {
            createDefaultChallenges()
        }
    }
    
    private func setupSubscriptions() {
        // Subscribe to challenges changes
        storageManager.$challenges
            .sink { [weak self] challenges in
                self?.allChallenges = challenges
            }
            .store(in: &cancellables)
        
        // Subscribe to user challenges changes
        storageManager.$userChallenges
            .sink { [weak self] challenges in
                guard let userId = self?.storageManager.currentUser?.id else { return }
                
                self?.userChallenges = challenges.filter { $0.userId == userId }
                self?.activeChallenges = challenges.filter { $0.userId == userId && $0.isActive }
                self?.completedChallenges = challenges.filter { $0.userId == userId && $0.isCompleted }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Challenge Management
    
    func getChallenge(by id: String) -> Challenge? {
        return allChallenges.first { $0.id == id }
    }
    
    func getUserChallenge(by id: String) -> UserChallenge? {
        return userChallenges.first { $0.id == id }
    }
    
    func startChallenge(challengeId: String) {
        guard let userId = storageManager.currentUser?.id,
              let challenge = getChallenge(by: challengeId) else { return }
        
        // Check if user already has this challenge
        if userChallenges.contains(where: { $0.challengeId == challengeId && $0.isActive }) {
            return
        }
        
        // Create task progress dictionary
        var taskProgress: [String: Bool] = [:]
        for task in challenge.tasks {
            taskProgress[task.id] = false
        }
        
        // Create user challenge
        let userChallenge = UserChallenge(
            userId: userId,
            challengeId: challengeId,
            taskProgress: taskProgress
        )
        
        storageManager.saveUserChallenge(userChallenge)
    }
    
    func completeTask(challengeId: String, taskId: String) {
        guard let index = userChallenges.firstIndex(where: { $0.challengeId == challengeId && $0.isActive }) else { return }
        
        var challenge = userChallenges[index]
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
    
    func abandonChallenge(challengeId: String) {
        guard let index = userChallenges.firstIndex(where: { $0.challengeId == challengeId && $0.isActive }) else { return }
        
        var challenge = userChallenges[index]
        challenge.isActive = false
        challenge.endDate = Date()
        
        storageManager.saveUserChallenge(challenge)
    }
    
    // MARK: - Default Challenges
    
    private func createDefaultChallenges() {
        let challenges = [
            Challenge(
                title: "7-Day Mindfulness",
                description: "Practice mindfulness techniques to help manage cravings and build awareness.",
                duration: 7,
                tasks: [
                    ChallengeTask(
                        title: "5-Minute Breathing",
                        description: "Spend 5 minutes focusing on your breath when you wake up."
                    ),
                    ChallengeTask(
                        title: "Craving Awareness",
                        description: "When a craving hits, observe it without judgment for 2 minutes before acting."
                    ),
                    ChallengeTask(
                        title: "Body Scan",
                        description: "Perform a 10-minute body scan meditation before bed."
                    ),
                    ChallengeTask(
                        title: "Mindful Walking",
                        description: "Take a 15-minute walk while focusing on each step and your surroundings."
                    )
                ]
            ),
            Challenge(
                title: "Healthy Habits Kickstart",
                description: "Replace addiction behaviors with healthy alternatives to rewire your brain.",
                duration: 14,
                tasks: [
                    ChallengeTask(
                        title: "Morning Exercise",
                        description: "Start your day with 10 minutes of physical activity."
                    ),
                    ChallengeTask(
                        title: "Hydration",
                        description: "Drink at least 8 glasses of water each day."
                    ),
                    ChallengeTask(
                        title: "Digital Detox",
                        description: "Spend 1 hour each day completely disconnected from screens."
                    ),
                    ChallengeTask(
                        title: "Healthy Meal",
                        description: "Prepare at least one nutritious meal from scratch each day."
                    ),
                    ChallengeTask(
                        title: "Journaling",
                        description: "Write down your thoughts and feelings for 5 minutes each evening."
                    )
                ]
            ),
            Challenge(
                title: "Social Connection",
                description: "Build a support network and strengthen relationships to help your recovery.",
                duration: 10,
                tasks: [
                    ChallengeTask(
                        title: "Recovery Buddy",
                        description: "Find someone you can talk to about your recovery journey."
                    ),
                    ChallengeTask(
                        title: "Honest Conversation",
                        description: "Have an open conversation with someone about your addiction."
                    ),
                    ChallengeTask(
                        title: "Group Activity",
                        description: "Participate in a group activity or event that doesn't involve your addiction."
                    ),
                    ChallengeTask(
                        title: "Help Others",
                        description: "Offer support or assistance to someone else in need."
                    )
                ]
            ),
            Challenge(
                title: "Trigger Management",
                description: "Identify and develop strategies to handle triggers that lead to cravings.",
                duration: 21,
                tasks: [
                    ChallengeTask(
                        title: "Trigger List",
                        description: "Create a list of your top 5 triggers and situations that lead to cravings."
                    ),
                    ChallengeTask(
                        title: "Avoidance Plan",
                        description: "Develop a plan to avoid or minimize exposure to each trigger."
                    ),
                    ChallengeTask(
                        title: "Coping Strategies",
                        description: "Create 3 specific coping strategies for when you can't avoid triggers."
                    ),
                    ChallengeTask(
                        title: "Environment Change",
                        description: "Modify your home environment to reduce trigger exposure."
                    ),
                    ChallengeTask(
                        title: "Practice Response",
                        description: "Practice your coping strategies when exposed to a trigger."
                    )
                ]
            )
        ]
        
        // Save challenges to storage
        for challenge in challenges {
            storageManager.saveChallenge(challenge)
        }
    }
} 