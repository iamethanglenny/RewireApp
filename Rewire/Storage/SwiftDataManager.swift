import Foundation
import SwiftData
import Combine

@MainActor
class SwiftDataManager: ObservableObject {
    // Singleton instance
    static let shared = SwiftDataManager()
    
    // Published properties for reactive UI updates
    @Published var currentUser: User?
    @Published var dailyLogs: [DailyLog] = []
    @Published var challenges: [Challenge] = []
    @Published var userChallenges: [UserChallenge] = []
    @Published var recoveryMilestones: [RecoveryMilestone] = []
    @Published var userRecoveryProgress: UserRecoveryProgress?
    
    // ModelContainer for SwiftData
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton
    private init() {
        do {
            // Create the model container with all our model types
            let schema = Schema([
                User.self,
                DailyLog.self,
                WellbeingRatings.self,
                CravingRecord.self,
                Challenge.self,
                ChallengeTask.self,
                UserChallenge.self,
                RecoveryMilestone.self,
                UserRecoveryProgress.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = modelContainer.mainContext
            
            // Load data
            loadData()
            
            // If no recovery milestones exist, create default ones
            if recoveryMilestones.isEmpty {
                createDefaultRecoveryMilestones()
            }
            
            // If no challenges exist, create default ones
            if challenges.isEmpty {
                createDefaultChallenges()
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        // Load user
        let userDescriptor = FetchDescriptor<User>()
        if let users = try? modelContext.fetch(userDescriptor), let user = users.first {
            currentUser = user
        }
        
        // Load daily logs
        let dailyLogDescriptor = FetchDescriptor<DailyLog>()
        if let logs = try? modelContext.fetch(dailyLogDescriptor) {
            dailyLogs = logs
        }
        
        // Load challenges
        let challengeDescriptor = FetchDescriptor<Challenge>()
        if let fetchedChallenges = try? modelContext.fetch(challengeDescriptor) {
            challenges = fetchedChallenges
        }
        
        // Load user challenges
        let userChallengeDescriptor = FetchDescriptor<UserChallenge>()
        if let fetchedUserChallenges = try? modelContext.fetch(userChallengeDescriptor) {
            userChallenges = fetchedUserChallenges
        }
        
        // Load recovery milestones
        let milestoneDescriptor = FetchDescriptor<RecoveryMilestone>()
        if let fetchedMilestones = try? modelContext.fetch(milestoneDescriptor) {
            recoveryMilestones = fetchedMilestones
        }
        
        // Load user recovery progress
        let progressDescriptor = FetchDescriptor<UserRecoveryProgress>()
        if let progress = try? modelContext.fetch(progressDescriptor).first {
            userRecoveryProgress = progress
        }
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String, addiction: AddictionType, quitDate: Date? = nil, costPerDay: Double? = nil, timeSpentPerDay: Double? = nil) -> User {
        let user = User(
            name: name,
            email: email,
            addiction: addiction,
            quitDate: quitDate,
            costPerDay: costPerDay,
            timeSpentPerDay: timeSpentPerDay
        )
        
        modelContext.insert(user)
        saveContext()
        currentUser = user
        
        // Create recovery progress if quit date is provided
        if let quitDate = quitDate {
            createUserRecoveryProgress(user: user, quitDate: quitDate)
        }
        
        return user
    }
    
    func updateUser(_ user: User) {
        // No need to explicitly update in SwiftData, just save the context
        saveContext()
        currentUser = user
    }
    
    func deleteUser(_ user: User) {
        modelContext.delete(user)
        saveContext()
        currentUser = nil
    }
    
    // MARK: - Daily Log Management
    
    func saveDailyLog(stayedClean: Bool, wellbeingRatings: WellbeingRatings, note: String? = nil) -> DailyLog? {
        guard let user = currentUser else { return nil }
        
        // Check if a log already exists for today
        let today = Calendar.current.startOfDay(for: Date())
        let dailyLog = getDailyLog(for: today) ?? DailyLog(date: today, stayedClean: stayedClean, note: note)
        
        // Set relationships
        dailyLog.user = user
        
        // Create wellbeing ratings if not exists
        if dailyLog.wellbeingRatings == nil {
            let ratings = WellbeingRatings(
                mood: wellbeingRatings.mood,
                energy: wellbeingRatings.energy,
                sleep: wellbeingRatings.sleep,
                cravingIntensity: wellbeingRatings.cravingIntensity
            )
            ratings.dailyLog = dailyLog
            dailyLog.wellbeingRatings = ratings
            modelContext.insert(ratings)
        } else {
            // Update existing ratings
            dailyLog.wellbeingRatings?.mood = wellbeingRatings.mood
            dailyLog.wellbeingRatings?.energy = wellbeingRatings.energy
            dailyLog.wellbeingRatings?.sleep = wellbeingRatings.sleep
            dailyLog.wellbeingRatings?.cravingIntensity = wellbeingRatings.cravingIntensity
        }
        
        // If this is a new log, insert it
        if dailyLog.user == nil {
            modelContext.insert(dailyLog)
            user.dailyLogs = (user.dailyLogs ?? []) + [dailyLog]
        }
        
        saveContext()
        
        // Update the published dailyLogs array
        if !dailyLogs.contains(where: { $0.id == dailyLog.id }) {
            dailyLogs.append(dailyLog)
        }
        
        return dailyLog
    }
    
    func getDailyLog(for date: Date) -> DailyLog? {
        guard let user = currentUser else { return nil }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<DailyLog> { log in
            log.user?.id == user.id &&
            log.date >= startOfDay &&
            log.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<DailyLog>(predicate: predicate)
        
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Error fetching daily log: \(error)")
            return nil
        }
    }
    
    func addCravingRecord(intensity: Int, duration: TimeInterval, trigger: String? = nil, location: String? = nil, overcame: Bool = true, notes: String? = nil) {
        guard let user = currentUser else { return }
        
        // Get or create today's log
        let today = Calendar.current.startOfDay(for: Date())
        let dailyLog = getDailyLog(for: today) ?? DailyLog(date: today)
        
        // Create craving record
        let craving = CravingRecord(
            timestamp: Date(),
            intensity: intensity,
            duration: duration,
            trigger: trigger,
            location: location,
            overcame: overcame,
            notes: notes
        )
        
        // Set relationships
        craving.dailyLog = dailyLog
        
        // Insert the craving
        modelContext.insert(craving)
        
        // Update the daily log's cravings array
        dailyLog.cravings = (dailyLog.cravings ?? []) + [craving]
        
        // If this is a new log, insert it and set relationships
        if dailyLog.user == nil {
            dailyLog.user = user
            modelContext.insert(dailyLog)
            user.dailyLogs = (user.dailyLogs ?? []) + [dailyLog]
        }
        
        saveContext()
        
        // Update the published dailyLogs array
        if !dailyLogs.contains(where: { $0.id == dailyLog.id }) {
            dailyLogs.append(dailyLog)
        }
    }
    
    // MARK: - Challenge Management
    
    func createChallenge(title: String, challengeDescription: String, difficulty: String, daysToComplete: Int, tasks: [ChallengeTask] = []) -> Challenge {
        let challenge = Challenge(
            title: title,
            challengeDescription: challengeDescription,
            difficulty: difficulty,
            daysToComplete: daysToComplete
        )
        
        modelContext.insert(challenge)
        
        // Add tasks to the challenge
        for task in tasks {
            task.challenge = challenge
            modelContext.insert(task)
        }
        
        challenge.tasks = tasks
        
        saveContext()
        challenges.append(challenge)
        
        return challenge
    }
    
    func startChallenge(challengeId: String) -> UserChallenge? {
        guard let user = currentUser,
              let challenge = challenges.first(where: { $0.id == challengeId }) else {
            return nil
        }
        
        // Check if user already has this challenge
        if userChallenges.contains(where: { $0.user?.id == user.id && $0.challenge?.id == challengeId && $0.isActive }) {
            return nil
        }
        
        // Create user challenge
        let userChallenge = UserChallenge(
            startDate: Date(),
            isActive: true,
            isCompleted: false,
            progress: 0.0
        )
        
        // Set relationships
        userChallenge.user = user
        userChallenge.challenge = challenge
        
        modelContext.insert(userChallenge)
        
        // Update relationships
        user.userChallenges = (user.userChallenges ?? []) + [userChallenge]
        challenge.userChallenges = (challenge.userChallenges ?? []) + [userChallenge]
        
        saveContext()
        userChallenges.append(userChallenge)
        
        return userChallenge
    }
    
    func completeTask(challengeId: String, taskId: String) -> Bool {
        guard let user = currentUser,
              let userChallenge = userChallenges.first(where: { $0.user?.id == user.id && $0.challenge?.id == challengeId && $0.isActive }),
              let challenge = userChallenge.challenge,
              let task = challenge.tasks?.first(where: { $0.id == taskId }) else {
            return false
        }
        
        // Mark task as completed
        task.isCompleted = true
        task.completionDate = Date()
        
        // Add to completed tasks
        userChallenge.completedTasks = (userChallenge.completedTasks ?? []) + [task]
        
        // Update progress
        if let totalTasks = challenge.tasks?.count, totalTasks > 0 {
            userChallenge.progress = Double(userChallenge.completedTasks?.count ?? 0) / Double(totalTasks)
        }
        
        // Check if all tasks are completed
        if userChallenge.progress >= 1.0 {
            userChallenge.isCompleted = true
            userChallenge.endDate = Date()
        }
        
        saveContext()
        return true
    }
    
    // MARK: - Recovery Progress Management
    
    func createUserRecoveryProgress(user: User, quitDate: Date) -> UserRecoveryProgress {
        let progress = UserRecoveryProgress(
            quitDate: quitDate,
            currentDay: 1
        )
        
        // Set relationships
        progress.user = user
        
        modelContext.insert(progress)
        
        // Update user relationship
        user.recoveryProgress = progress
        
        saveContext()
        userRecoveryProgress = progress
        
        return progress
    }
    
    func updateRecoveryProgress() {
        guard let progress = userRecoveryProgress else { return }
        
        // Update current day
        progress.currentDay = progress.calculateCurrentDay()
        
        saveContext()
    }
    
    func completeRecoveryMilestone(milestoneId: String) -> Bool {
        guard let progress = userRecoveryProgress,
              let milestone = recoveryMilestones.first(where: { $0.id == milestoneId }) else {
            return false
        }
        
        // Add to completed milestones if not already completed
        if !(progress.completedMilestones?.contains(milestone) ?? false) {
            progress.completedMilestones = (progress.completedMilestones ?? []) + [milestone]
            saveContext()
            return true
        }
        
        return false
    }
    
    // MARK: - Default Data Creation
    
    private func createDefaultRecoveryMilestones() {
        // Create default milestones for each addiction type
        for addictionType in [AddictionType.smoking, .alcohol, .gambling, .socialMedia, .pornography, .gaming, .shopping, .other] {
            // Example milestones - these would be customized for each addiction type
            let milestones = [
                RecoveryMilestone(
                    addictionType: addictionType,
                    dayRange: "Days 1-3",
                    title: "Initial Withdrawal",
                    description: "The first few days are the hardest as your body adjusts to life without the substance.",
                    startDay: 1,
                    endDay: 3
                ),
                RecoveryMilestone(
                    addictionType: addictionType,
                    dayRange: "Days 4-7",
                    title: "Physical Recovery Begins",
                    description: "Your body starts to heal and adjust to the absence of the substance.",
                    startDay: 4,
                    endDay: 7
                ),
                RecoveryMilestone(
                    addictionType: addictionType,
                    dayRange: "Days 8-14",
                    title: "Mental Clarity",
                    description: "Brain fog begins to lift and you start to think more clearly.",
                    startDay: 8,
                    endDay: 14
                ),
                RecoveryMilestone(
                    addictionType: addictionType,
                    dayRange: "Days 15-30",
                    title: "New Habits Form",
                    description: "You begin to establish new, healthier routines and habits.",
                    startDay: 15,
                    endDay: 30
                ),
                RecoveryMilestone(
                    addictionType: addictionType,
                    dayRange: "Days 31-90",
                    title: "Lifestyle Change",
                    description: "Your new lifestyle becomes more natural and sustainable.",
                    startDay: 31,
                    endDay: 90
                )
            ]
            
            // Insert milestones
            for milestone in milestones {
                modelContext.insert(milestone)
                recoveryMilestones.append(milestone)
            }
        }
        
        saveContext()
    }
    
    private func createDefaultChallenges() {
        // Create some default challenges
        let challenges = [
            (
                title: "Mindfulness Challenge",
                challengeDescription: "Practice mindfulness techniques daily to help manage cravings and stress.",
                difficulty: "Easy",
                daysToComplete: 10,
                tasks: [
                    ChallengeTask(title: "5-Minute Meditation", taskDescription: "Spend 5 minutes in quiet meditation."),
                    ChallengeTask(title: "Mindful Walking", taskDescription: "Take a 10-minute walk focusing on your surroundings."),
                    ChallengeTask(title: "Deep Breathing", taskDescription: "Practice deep breathing exercises for 5 minutes."),
                    ChallengeTask(title: "Body Scan", taskDescription: "Perform a full body scan meditation."),
                    ChallengeTask(title: "Mindful Eating", taskDescription: "Eat a meal with full attention to the experience.")
                ]
            ),
            (
                title: "Healthy Habits",
                challengeDescription: "Establish healthy habits to replace addiction behaviors.",
                difficulty: "Medium",
                daysToComplete: 14,
                tasks: [
                    ChallengeTask(title: "Morning Exercise", taskDescription: "Start your day with 15 minutes of exercise."),
                    ChallengeTask(title: "Hydration", taskDescription: "Drink at least 8 glasses of water daily."),
                    ChallengeTask(title: "Sleep Routine", taskDescription: "Establish a consistent sleep schedule."),
                    ChallengeTask(title: "Healthy Meal", taskDescription: "Prepare a nutritious meal instead of eating out."),
                    ChallengeTask(title: "Digital Detox", taskDescription: "Spend 2 hours without digital devices.")
                ]
            ),
            (
                title: "Connection Challenge",
                challengeDescription: "Rebuild and strengthen social connections.",
                difficulty: "Hard",
                daysToComplete: 21,
                tasks: [
                    ChallengeTask(title: "Reach Out", taskDescription: "Contact a friend or family member you haven't spoken to in a while."),
                    ChallengeTask(title: "Join a Group", taskDescription: "Attend a community event or support group."),
                    ChallengeTask(title: "Volunteer", taskDescription: "Spend time volunteering for a cause you care about."),
                    ChallengeTask(title: "Share Your Journey", taskDescription: "Open up to someone about your recovery journey."),
                    ChallengeTask(title: "Plan a Social Activity", taskDescription: "Organize a social gathering that doesn't involve your addiction.")
                ]
            )
        ]
        
        // Insert challenges
        for challenge in challenges {
            let newChallenge = Challenge(
                title: challenge.title,
                challengeDescription: challenge.challengeDescription,
                difficulty: challenge.difficulty,
                daysToComplete: challenge.daysToComplete
            )
            
            modelContext.insert(newChallenge)
            
            // Create and add tasks
            var challengeTasks: [ChallengeTask] = []
            for task in challenge.tasks {
                let newTask = ChallengeTask(
                    title: task.title,
                    taskDescription: task.taskDescription
                )
                newTask.challenge = newChallenge
                modelContext.insert(newTask)
                challengeTasks.append(newTask)
            }
            
            newChallenge.tasks = challengeTasks
            self.challenges.append(newChallenge)
        }
        
        saveContext()
    }
    
    // MARK: - Migration
    
    func migrateFromFileStorage(storageManager: StorageManager) {
        // Migrate user
        if let user = storageManager.currentUser {
            // Create new user with basic properties
            let newUser = User(
                name: user.name,
                email: user.email,
                addiction: AddictionType.other // Default value, will be updated if possible
            )
            
            // Try to set addiction type if available
            if let addictionString = (user.value(forKey: "addiction") as? String) ?? (user.value(forKey: "addictionType") as? String) {
                if let addiction = AddictionType(rawValue: addictionString) {
                    newUser.addiction = addiction
                }
            }
            
            // Try to set other properties if available
            if let quitDate = user.value(forKey: "quitDate") as? Date {
                newUser.quitDate = quitDate
            }
            
            if let costPerDay = user.value(forKey: "costPerDay") as? Double {
                newUser.costPerDay = costPerDay
            }
            
            if let timeSpentPerDay = user.value(forKey: "timeSpentPerDay") as? Double {
                newUser.timeSpentPerDay = timeSpentPerDay
            }
            
            // Insert the user
            modelContext.insert(newUser)
            currentUser = newUser
            
            // MARK: Migrate Daily Logs
            
            // Get all logs (we'll filter them later)
            let allLogs = storageManager.dailyLogs
            
            for log in allLogs {
                // Try to get the user ID from the log
                let logUserId = (log.value(forKey: "userId") as? String) ?? ""
                
                // Skip logs that don't belong to this user
                if !logUserId.isEmpty && logUserId != user.id {
                    continue
                }
                
                // Create new log with basic properties
                let newLog = DailyLog(
                    id: log.id,
                    date: log.date,
                    stayedClean: (log.value(forKey: "stayedClean") as? Bool) ?? true
                )
                
                // Try to set note if available
                if let note = log.value(forKey: "note") as? String {
                    newLog.note = note
                }
                
                // Set relationship to user
                newLog.user = newUser
                
                // Try to create wellbeing ratings if available
                if let wellbeingRatings = log.value(forKey: "wellbeingRatings") {
                    let ratings = WellbeingRatings(
                        id: UUID().uuidString,
                        mood: (wellbeingRatings.value(forKey: "mood") as? Int) ?? 3,
                        energy: (wellbeingRatings.value(forKey: "energy") as? Int) ?? 3,
                        sleep: (wellbeingRatings.value(forKey: "sleep") as? Int) ?? 3,
                        cravingIntensity: (wellbeingRatings.value(forKey: "cravingIntensity") as? Int) ?? 3
                    )
                    
                    ratings.dailyLog = newLog
                    newLog.wellbeingRatings = ratings
                    modelContext.insert(ratings)
                }
                
                // Try to create cravings if available
                var cravingRecords: [CravingRecord] = []
                if let cravings = log.value(forKey: "cravings") as? [Any] {
                    for cravingObj in cravings {
                        // Extract properties safely
                        let id = (cravingObj.value(forKey: "id") as? String) ?? UUID().uuidString
                        let timestamp = (cravingObj.value(forKey: "timestamp") as? Date) ?? Date()
                        let intensity = (cravingObj.value(forKey: "intensity") as? Int) ?? 3
                        let duration = (cravingObj.value(forKey: "duration") as? TimeInterval) ?? 0
                        let trigger = cravingObj.value(forKey: "trigger") as? String
                        let location = cravingObj.value(forKey: "location") as? String
                        let overcame = (cravingObj.value(forKey: "overcame") as? Bool) ?? true
                        let notes = cravingObj.value(forKey: "notes") as? String
                        
                        let newCraving = CravingRecord(
                            id: id,
                            timestamp: timestamp,
                            intensity: intensity,
                            duration: duration,
                            trigger: trigger,
                            location: location,
                            overcame: overcame,
                            notes: notes
                        )
                        
                        newCraving.dailyLog = newLog
                        cravingRecords.append(newCraving)
                        modelContext.insert(newCraving)
                    }
                }
                
                newLog.cravings = cravingRecords
                
                modelContext.insert(newLog)
                
                // Update user relationship
                newUser.dailyLogs = (newUser.dailyLogs ?? []) + [newLog]
            }
            
            // MARK: Migrate Recovery Progress
            
            if let progress = storageManager.userRecoveryProgress {
                // Try to get the user ID from the progress
                let progressUserId = (progress.value(forKey: "userId") as? String) ?? ""
                
                // Skip if the progress doesn't belong to this user
                if !progressUserId.isEmpty && progressUserId != user.id {
                    // Skip this progress
                } else {
                    // Create new progress with basic properties
                    let newProgress = UserRecoveryProgress(
                        id: (progress.value(forKey: "id") as? String) ?? UUID().uuidString,
                        quitDate: (progress.value(forKey: "quitDate") as? Date) ?? Date(),
                        currentDay: (progress.value(forKey: "currentDay") as? Int) ?? 1
                    )
                    
                    // Set relationship to user
                    newProgress.user = newUser
                    
                    // Try to get completed milestone IDs
                    var completedMilestones: [RecoveryMilestone] = []
                    var milestoneIds: [String] = []
                    
                    if let ids = progress.value(forKey: "completedMilestoneIds") as? [String] {
                        milestoneIds = ids
                    } else if let ids = progress.value(forKey: "completedMilestones") as? [String] {
                        milestoneIds = ids
                    }
                    
                    // Find matching milestones
                    for milestoneId in milestoneIds {
                        if let milestone = recoveryMilestones.first(where: { $0.id == milestoneId }) {
                            completedMilestones.append(milestone)
                        }
                    }
                    
                    newProgress.completedMilestones = completedMilestones
                    
                    modelContext.insert(newProgress)
                    
                    // Update user relationship
                    newUser.recoveryProgress = newProgress
                }
            }
            
            // MARK: Migrate User Challenges
            
            // Get all user challenges
            let allUserChallenges = storageManager.userChallenges
            
            for userChallenge in allUserChallenges {
                // Try to get the user ID from the challenge
                let challengeUserId = (userChallenge.value(forKey: "userId") as? String) ?? ""
                
                // Skip challenges that don't belong to this user
                if !challengeUserId.isEmpty && challengeUserId != user.id {
                    continue
                }
                
                // Try to get the challenge ID
                var challengeId: String? = nil
                
                if let id = userChallenge.value(forKey: "challengeId") as? String {
                    challengeId = id
                } else if let challenge = userChallenge.value(forKey: "challenge"),
                          let id = challenge.value(forKey: "id") as? String {
                    challengeId = id
                }
                
                // Find the matching challenge
                if let challengeId = challengeId,
                   let challenge = challenges.first(where: { $0.id == challengeId }) {
                    // Create new user challenge with basic properties
                    let newUserChallenge = UserChallenge(
                        id: (userChallenge.value(forKey: "id") as? String) ?? UUID().uuidString,
                        startDate: (userChallenge.value(forKey: "startDate") as? Date) ?? Date(),
                        endDate: userChallenge.value(forKey: "endDate") as? Date,
                        isActive: (userChallenge.value(forKey: "isActive") as? Bool) ?? true,
                        isCompleted: (userChallenge.value(forKey: "isCompleted") as? Bool) ?? false,
                        progress: (userChallenge.value(forKey: "progress") as? Double) ?? 0.0
                    )
                    
                    // Set relationships
                    newUserChallenge.user = newUser
                    newUserChallenge.challenge = challenge
                    
                    // Try to get completed tasks
                    var completedTasks: [ChallengeTask] = []
                    
                    // Try different approaches to get completed tasks
                    if let taskProgress = userChallenge.value(forKey: "taskProgress") as? [String: Bool] {
                        for (taskId, completed) in taskProgress where completed {
                            if let task = challenge.tasks?.first(where: { $0.id == taskId }) {
                                completedTasks.append(task)
                            }
                        }
                    } else if let completedTasksArray = userChallenge.value(forKey: "completedTasks") as? [Any] {
                        for taskObj in completedTasksArray {
                            if let taskId = taskObj.value(forKey: "id") as? String,
                               let task = challenge.tasks?.first(where: { $0.id == taskId }) {
                                completedTasks.append(task)
                            }
                        }
                    }
                    
                    newUserChallenge.completedTasks = completedTasks
                    
                    modelContext.insert(newUserChallenge)
                    
                    // Update relationships
                    newUser.userChallenges = (newUser.userChallenges ?? []) + [newUserChallenge]
                    challenge.userChallenges = (challenge.userChallenges ?? []) + [newUserChallenge]
                }
            }
            
            // Save all changes
            saveContext()
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 