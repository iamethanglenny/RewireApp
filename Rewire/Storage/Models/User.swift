import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var email: String
    var joinDate: Date
    var streakDays: Int
    var totalCleanDays: Int
    var addiction: Addiction
    var settings: UserSettings
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         joinDate: Date = Date(),
         streakDays: Int = 0,
         totalCleanDays: Int = 0,
         addiction: Addiction,
         settings: UserSettings = UserSettings()) {
        self.id = id
        self.name = name
        self.email = email
        self.joinDate = joinDate
        self.streakDays = streakDays
        self.totalCleanDays = totalCleanDays
        self.addiction = addiction
        self.settings = settings
    }
}

struct Addiction: Codable {
    var type: AddictionType
    var quitDate: Date?
    var costPerDay: Double?
    var timeSpentPerDay: Double? // In minutes
    
    init(type: AddictionType, 
         quitDate: Date? = nil, 
         costPerDay: Double? = nil, 
         timeSpentPerDay: Double? = nil) {
        self.type = type
        self.quitDate = quitDate
        self.costPerDay = costPerDay
        self.timeSpentPerDay = timeSpentPerDay
    }
}

enum AddictionType: String, Codable, CaseIterable {
    case smoking = "Smoking"
    case alcohol = "Alcohol"
    case gambling = "Gambling"
    case socialMedia = "Social Media"
    case pornography = "Pornography"
    case gaming = "Gaming"
    case other = "Other"
}

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