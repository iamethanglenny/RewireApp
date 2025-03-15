import Foundation
import Combine

class StorageManager: ObservableObject {
    // Singleton instance
    static let shared = StorageManager()
    
    // Published properties for reactive UI updates
    @Published var currentUser: User?
    @Published var dailyLogs: [DailyLog] = []
    @Published var challenges: [Challenge] = []
    @Published var userChallenges: [UserChallenge] = []
    @Published var recoveryMilestones: [RecoveryMilestone] = []
    @Published var userRecoveryProgress: UserRecoveryProgress?
    
    // File URLs for storage
    private let userURL: URL
    private let dailyLogsURL: URL
    private let challengesURL: URL
    private let userChallengesURL: URL
    private let recoveryMilestonesURL: URL
    private let userRecoveryProgressURL: URL
    
    // Private initializer for singleton
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appDirectory = documentsDirectory.appendingPathComponent("RewireApp", isDirectory: true)
        
        // Create app directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        // Set up file URLs
        userURL = appDirectory.appendingPathComponent("user.json")
        dailyLogsURL = appDirectory.appendingPathComponent("dailyLogs.json")
        challengesURL = appDirectory.appendingPathComponent("challenges.json")
        userChallengesURL = appDirectory.appendingPathComponent("userChallenges.json")
        recoveryMilestonesURL = appDirectory.appendingPathComponent("recoveryMilestones.json")
        userRecoveryProgressURL = appDirectory.appendingPathComponent("userRecoveryProgress.json")
        
        // Load data
        loadData()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        currentUser = loadFromFile(User.self, from: userURL)
        dailyLogs = loadArrayFromFile([DailyLog].self, from: dailyLogsURL) ?? []
        challenges = loadArrayFromFile([Challenge].self, from: challengesURL) ?? []
        userChallenges = loadArrayFromFile([UserChallenge].self, from: userChallengesURL) ?? []
        recoveryMilestones = loadArrayFromFile([RecoveryMilestone].self, from: recoveryMilestonesURL) ?? []
        userRecoveryProgress = loadFromFile(UserRecoveryProgress.self, from: userRecoveryProgressURL)
        
        // If no recovery milestones exist, create default ones
        if recoveryMilestones.isEmpty {
            createDefaultRecoveryMilestones()
        }
    }
    
    private func loadFromFile<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("Error loading \(type) from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
    
    private func loadArrayFromFile<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("Error loading \(type) from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
    
    // MARK: - Data Saving
    
    private func saveToFile<T: Encodable>(_ object: T, to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(object)
            try data.write(to: url)
        } catch {
            print("Error saving to \(url.lastPathComponent): \(error)")
        }
    }
    
    // MARK: - User Management
    
    func saveUser(_ user: User) {
        currentUser = user
        saveToFile(user, to: userURL)
    }
    
    func updateUser(name: String? = nil, email: String? = nil, streakDays: Int? = nil, 
                   totalCleanDays: Int? = nil, addiction: Addiction? = nil, settings: UserSettings? = nil) {
        guard var user = currentUser else { return }
        
        if let name = name { user.name = name }
        if let email = email { user.email = email }
        if let streakDays = streakDays { user.streakDays = streakDays }
        if let totalCleanDays = totalCleanDays { user.totalCleanDays = totalCleanDays }
        if let addiction = addiction { user.addiction = addiction }
        if let settings = settings { user.settings = settings }
        
        saveUser(user)
    }
    
    // MARK: - Daily Logs Management
    
    func saveDailyLog(_ log: DailyLog) {
        if let index = dailyLogs.firstIndex(where: { $0.id == log.id }) {
            dailyLogs[index] = log
        } else {
            dailyLogs.append(log)
        }
        saveToFile(dailyLogs, to: dailyLogsURL)
    }
    
    func getDailyLog(for date: Date) -> DailyLog? {
        let calendar = Calendar.current
        return dailyLogs.first { log in
            calendar.isDate(log.date, inSameDayAs: date)
        }
    }
    
    func getDailyLogs(startDate: Date, endDate: Date) -> [DailyLog] {
        return dailyLogs.filter { log in
            log.date >= startDate && log.date <= endDate
        }.sorted { $0.date > $1.date }
    }
    
    func addCravingRecord(_ craving: CravingRecord, to date: Date) {
        let calendar = Calendar.current
        if var log = dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            log.cravings.append(craving)
            saveDailyLog(log)
        } else if let userId = currentUser?.id {
            // Create a new log if one doesn't exist for today
            let newLog = DailyLog(
                userId: userId,
                date: date,
                cravings: [craving]
            )
            saveDailyLog(newLog)
        }
    }
    
    // MARK: - Challenges Management
    
    func saveChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = challenge
        } else {
            challenges.append(challenge)
        }
        saveToFile(challenges, to: challengesURL)
    }
    
    func saveUserChallenge(_ userChallenge: UserChallenge) {
        if let index = userChallenges.firstIndex(where: { $0.id == userChallenge.id }) {
            userChallenges[index] = userChallenge
        } else {
            userChallenges.append(userChallenge)
        }
        saveToFile(userChallenges, to: userChallengesURL)
    }
    
    func getUserChallenges(for userId: String) -> [UserChallenge] {
        return userChallenges.filter { $0.userId == userId }
    }
    
    func getActiveUserChallenges(for userId: String) -> [UserChallenge] {
        return userChallenges.filter { $0.userId == userId && $0.isActive }
    }
    
    // MARK: - Recovery Management
    
    func saveRecoveryMilestone(_ milestone: RecoveryMilestone) {
        if let index = recoveryMilestones.firstIndex(where: { $0.id == milestone.id }) {
            recoveryMilestones[index] = milestone
        } else {
            recoveryMilestones.append(milestone)
        }
        saveToFile(recoveryMilestones, to: recoveryMilestonesURL)
    }
    
    func saveUserRecoveryProgress(_ progress: UserRecoveryProgress) {
        userRecoveryProgress = progress
        saveToFile(progress, to: userRecoveryProgressURL)
    }
    
    func getMilestones(for addictionType: AddictionType) -> [RecoveryMilestone] {
        return recoveryMilestones.filter { $0.addictionType == addictionType }
            .sorted { $0.startDay < $1.startDay }
    }
    
    func updateUserRecoveryProgress() {
        guard var progress = userRecoveryProgress else { return }
        
        // Update current day
        progress.currentDay = progress.calculateCurrentDay()
        
        // Save updated progress
        saveUserRecoveryProgress(progress)
    }
    
    // MARK: - Default Data Creation
    
    private func createDefaultRecoveryMilestones() {
        // Create default recovery milestones for different addiction types
        let smokingMilestones = [
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 1-3",
                title: "Nicotine Withdrawal",
                description: "Your body is clearing out nicotine and adjusting to its absence. You may experience cravings, irritability, and headaches.",
                startDay: 1,
                endDay: 3
            ),
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 4-7",
                title: "Physical Recovery",
                description: "Your sense of taste and smell begin to improve. Breathing becomes easier as your lungs start to heal.",
                startDay: 4,
                endDay: 7
            ),
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 8-14",
                title: "Energy Boost",
                description: "Blood circulation improves, and you may notice increased energy levels and improved lung function.",
                startDay: 8,
                endDay: 14
            ),
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 15-30",
                title: "Habit Breaking",
                description: "The psychological addiction begins to weaken. Your brain is forming new, healthier habits.",
                startDay: 15,
                endDay: 30
            ),
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 31-90",
                title: "Lung Healing",
                description: "Your lung function continues to improve. Cilia in your lungs regrow, helping to clean your lungs and reduce infection risk.",
                startDay: 31,
                endDay: 90
            ),
            RecoveryMilestone(
                addictionType: .smoking,
                dayRange: "Days 91-365",
                title: "Long-term Benefits",
                description: "Your risk of heart disease has dropped significantly. Lung cancer risk begins to decrease.",
                startDay: 91,
                endDay: 365
            )
        ]
        
        // Add the milestones to the array
        recoveryMilestones.append(contentsOf: smokingMilestones)
        
        // Save to file
        saveToFile(recoveryMilestones, to: recoveryMilestonesURL)
    }
} 