import Foundation
import SwiftData

// MARK: - Challenge Model

@Model
final class Challenge {
    @Attribute(.unique) var id: String
    var title: String
    var challengeDescription: String
    var difficulty: String
    var daysToComplete: Int
    var progress: Double
    
    // Relationships
    @Relationship(deleteRule: .cascade) var tasks: [ChallengeTask]?
    @Relationship(deleteRule: .cascade) var userChallenges: [UserChallenge]?
    
    init(id: String = UUID().uuidString,
         title: String,
         challengeDescription: String,
         difficulty: String,
         daysToComplete: Int,
         progress: Double = 0.0) {
        self.id = id
        self.title = title
        self.challengeDescription = challengeDescription
        self.difficulty = difficulty
        self.daysToComplete = daysToComplete
        self.progress = progress
    }
    
    convenience init(id: String = UUID().uuidString,
         title: String,
         challengeDescription: String,
         duration: Int) {
        self.init(
            id: id,
            title: title,
            challengeDescription: challengeDescription,
            difficulty: duration <= 7 ? "Easy" : (duration <= 14 ? "Medium" : "Hard"),
            daysToComplete: duration,
            progress: 0.0
        )
    }
}

// MARK: - ChallengeTask Model

@Model
final class ChallengeTask {
    @Attribute(.unique) var id: String
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var completionDate: Date?
    
    // Relationships
    var challenge: Challenge?
    
    init(id: String = UUID().uuidString,
         title: String,
         taskDescription: String,
         isCompleted: Bool = false,
         completionDate: Date? = nil) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.completionDate = completionDate
    }
}

// MARK: - UserChallenge Model

@Model
final class UserChallenge {
    @Attribute(.unique) var id: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var isCompleted: Bool
    var progress: Double // 0.0 to 1.0
    
    // Relationships
    var user: User?
    var challenge: Challenge?
    @Relationship(deleteRule: .cascade) var completedTasks: [ChallengeTask]?
    
    init(id: String = UUID().uuidString,
         startDate: Date = Date(),
         endDate: Date? = nil,
         isActive: Bool = true,
         isCompleted: Bool = false,
         progress: Double = 0.0) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.progress = progress
    }
    
    // Helper method to check if a task is completed
    func isTaskCompleted(task: ChallengeTask) -> Bool {
        return completedTasks?.contains(task) ?? false
    }
}
