import Foundation


struct ChallengeTask: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var isCompleted: Bool
    var completionDate: Date?
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         isCompleted: Bool = false,
         completionDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.completionDate = completionDate
    }
}

struct UserChallenge: Codable, Identifiable {
    var id: String
    var userId: String
    var challengeId: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var isCompleted: Bool
    var progress: Double // 0.0 to 1.0
    var taskProgress: [String: Bool] // task id to completion status
    
    init(id: String = UUID().uuidString,
         userId: String,
         challengeId: String,
         startDate: Date = Date(),
         endDate: Date? = nil,
         isActive: Bool = true,
         isCompleted: Bool = false,
         progress: Double = 0.0,
         taskProgress: [String: Bool] = [:]) {
        self.id = id
        self.userId = userId
        self.challengeId = challengeId
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.progress = progress
        self.taskProgress = taskProgress
    }
} 
