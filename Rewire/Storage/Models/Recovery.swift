import Foundation

struct RecoveryMilestone: Codable, Identifiable {
    var id: String
    var addictionType: AddictionType
    var dayRange: String // e.g., "Days 1-3", "Days 4-7", etc.
    var title: String
    var description: String
    var startDay: Int
    var endDay: Int
    
    init(id: String = UUID().uuidString,
         addictionType: AddictionType,
         dayRange: String,
         title: String,
         description: String,
         startDay: Int,
         endDay: Int) {
        self.id = id
        self.addictionType = addictionType
        self.dayRange = dayRange
        self.title = title
        self.description = description
        self.startDay = startDay
        self.endDay = endDay
    }
}

struct UserRecoveryProgress: Codable, Identifiable {
    var id: String
    var userId: String
    var addictionType: AddictionType
    var quitDate: Date
    var currentDay: Int
    var completedMilestones: [String] // milestone ids
    
    init(id: String = UUID().uuidString,
         userId: String,
         addictionType: AddictionType,
         quitDate: Date,
         currentDay: Int = 1,
         completedMilestones: [String] = []) {
        self.id = id
        self.userId = userId
        self.addictionType = addictionType
        self.quitDate = quitDate
        self.currentDay = currentDay
        self.completedMilestones = completedMilestones
    }
    
    // Calculate current day based on quit date
    func calculateCurrentDay() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(1, (components.day ?? 0) + 1)
    }
    
    // Check if a milestone is completed
    func isMilestoneCompleted(milestoneId: String) -> Bool {
        return completedMilestones.contains(milestoneId)
    }
    
    // Check if a milestone is in progress
    func isMilestoneInProgress(milestone: RecoveryMilestone) -> Bool {
        return currentDay >= milestone.startDay && currentDay <= milestone.endDay
    }
} 