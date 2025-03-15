import Foundation
import SwiftData

// MARK: - User Model

@Model
final class User {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var addiction: AddictionType
    var quitDate: Date?
    var costPerDay: Double?
    var timeSpentPerDay: Double?
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var dailyLogs: [DailyLog]?
    @Relationship(deleteRule: .cascade) var userChallenges: [UserChallenge]?
    @Relationship(deleteRule: .cascade) var recoveryProgress: UserRecoveryProgress?
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         addiction: AddictionType,
         quitDate: Date? = nil,
         costPerDay: Double? = nil,
         timeSpentPerDay: Double? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.addiction = addiction
        self.quitDate = quitDate
        self.costPerDay = costPerDay
        self.timeSpentPerDay = timeSpentPerDay
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Addiction Type Enum

enum AddictionType: String, Codable {
    case smoking = "smoking"
    case alcohol = "alcohol"
    case gambling = "gambling"
    case socialMedia = "socialMedia"
    case pornography = "pornography"
    case gaming = "gaming"
    case shopping = "shopping"
    case other = "other"
}

// Make AddictionType conform to Hashable for SwiftData
extension AddictionType: Hashable {}

struct UserSettings: Codable {
    var notificationsEnabled: Bool
    var dailyReminderTime: Date
    var darkModeEnabled: Bool
    var privacyMode: Bool
    
    init(notificationsEnabled: Bool = true,
         dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
         darkModeEnabled: Bool = true,
         privacyMode: Bool = false) {
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.darkModeEnabled = darkModeEnabled
        self.privacyMode = privacyMode
    }
}