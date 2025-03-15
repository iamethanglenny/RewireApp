import Foundation
import SwiftData

// MARK: - DailyLog Model

@Model
final class DailyLog {
    @Attribute(.unique) var id: String
    var date: Date
    var stayedClean: Bool
    var note: String?
    
    // Relationships
    @Relationship(.cascade) var wellbeingRatings: WellbeingRatings?
    @Relationship(.cascade) var cravings: [CravingRecord]?
    var user: User?
    
    init(id: String = UUID().uuidString,
         date: Date = Date(),
         stayedClean: Bool = true,
         note: String? = nil) {
        self.id = id
        self.date = date
        self.stayedClean = stayedClean
        self.note = note
    }
}

// MARK: - WellbeingRatings Model

@Model
final class WellbeingRatings {
    @Attribute(.unique) var id: String
    var mood: Int
    var energy: Int
    var sleep: Int
    var cravingIntensity: Int
    
    // Relationships
    var dailyLog: DailyLog?
    
    init(id: String = UUID().uuidString,
         mood: Int = 3, 
         energy: Int = 3, 
         sleep: Int = 3, 
         cravingIntensity: Int = 3) {
        self.id = id
        self.mood = mood
        self.energy = energy
        self.sleep = sleep
        self.cravingIntensity = cravingIntensity
    }
}

// MARK: - CravingRecord Model

@Model
final class CravingRecord {
    @Attribute(.unique) var id: String
    var timestamp: Date
    var intensity: Int // 1-5 scale
    var duration: TimeInterval // in seconds
    var trigger: String?
    var location: String?
    var overcame: Bool
    var notes: String?
    
    // Relationships
    var dailyLog: DailyLog?
    
    init(id: String = UUID().uuidString,
         timestamp: Date = Date(),
         intensity: Int,
         duration: TimeInterval,
         trigger: String? = nil,
         location: String? = nil,
         overcame: Bool = true,
         notes: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.duration = duration
        self.trigger = trigger
        self.location = location
        self.overcame = overcame
        self.notes = notes
    }
} 