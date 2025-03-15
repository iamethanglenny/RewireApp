import Foundation

struct DailyLog: Codable, Identifiable {
    var id: String
    var userId: String
    var date: Date
    var stayedClean: Bool
    var wellbeingRatings: WellbeingRatings
    var note: String?
    var cravings: [CravingRecord]
    
    init(id: String = UUID().uuidString,
         userId: String,
         date: Date = Date(),
         stayedClean: Bool = true,
         wellbeingRatings: WellbeingRatings = WellbeingRatings(),
         note: String? = nil,
         cravings: [CravingRecord] = []) {
        self.id = id
        self.userId = userId
        self.date = date
        self.stayedClean = stayedClean
        self.wellbeingRatings = wellbeingRatings
        self.note = note
        self.cravings = cravings
    }
}

struct WellbeingRatings: Codable {
    var mood: Int
    var energy: Int
    var sleep: Int
    var cravingIntensity: Int
    
    init(mood: Int = 3, energy: Int = 3, sleep: Int = 3, cravingIntensity: Int = 3) {
        self.mood = mood
        self.energy = energy
        self.sleep = sleep
        self.cravingIntensity = cravingIntensity
    }
}

struct CravingRecord: Codable, Identifiable {
    var id: String
    var timestamp: Date
    var intensity: Int // 1-5 scale
    var duration: TimeInterval // in seconds
    var trigger: String?
    var location: String?
    var overcame: Bool
    var notes: String?
    
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