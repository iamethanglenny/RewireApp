import Foundation
import SwiftData

// MARK: - RecoveryMilestone Model

@Model
final class RecoveryMilestone {
    @Attribute(.unique) var id: String
    var addictionType: AddictionType
    var dayRange: String // e.g., "Days 1-3", "Days 4-7", etc.
    var title: String
    var milestoneDescription: String
    var startDay: Int
    var endDay: Int
    
    // Relationships
    @Relationship(deleteRule: .cascade) var userProgress: [UserRecoveryProgress]?
    
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
        self.milestoneDescription = description
        self.startDay = startDay
        self.endDay = endDay
    }
}

// MARK: - UserRecoveryProgress Model

@Model
final class UserRecoveryProgress {
    @Attribute(.unique) var id: String
    var quitDate: Date
    var currentDay: Int
    
    // Relationships
    var user: User?
    @Relationship(deleteRule: .cascade) var completedMilestones: [RecoveryMilestone]?
    
    init(id: String = UUID().uuidString,
         quitDate: Date,
         currentDay: Int = 1) {
        self.id = id
        self.quitDate = quitDate
        self.currentDay = currentDay
    }
    
    // Calculate current day based on quit date
    func calculateCurrentDay() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(1, (components.day ?? 0) + 1)
    }
    
    // Check if a milestone is completed
    func isMilestoneCompleted(milestone: RecoveryMilestone) -> Bool {
        return completedMilestones?.contains(milestone) ?? false
    }
    
    // Check if a milestone is in progress
    func isMilestoneInProgress(milestone: RecoveryMilestone) -> Bool {
        return currentDay >= milestone.startDay && currentDay <= milestone.endDay
    }
}