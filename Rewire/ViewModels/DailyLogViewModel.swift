import Foundation
import SwiftUI

class DailyLogViewModel: ObservableObject {
    private let dataManager = DataManager.shared
    
    @Published var didVape: Bool = false
    @Published var moodScore: Int = 3
    @Published var energyScore: Int = 3
    @Published var sleepScore: Int = 3
    @Published var cravingsScore: Int = 3
    @Published var notes: String = ""
    
    var moodDescription: String {
        switch moodScore {
        case 1: return "Very poor"
        case 2: return "Poor"
        case 3: return "Average"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return ""
        }
    }
    
    var energyDescription: String {
        switch energyScore {
        case 1: return "Very low"
        case 2: return "Low"
        case 3: return "Average"
        case 4: return "High"
        case 5: return "Very high"
        default: return ""
        }
    }
    
    var sleepDescription: String {
        switch sleepScore {
        case 1: return "Very poor"
        case 2: return "Poor"
        case 3: return "Average"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return ""
        }
    }
    
    var cravingsDescription: String {
        switch cravingsScore {
        case 1: return "Very strong"
        case 2: return "Strong"
        case 3: return "Moderate"
        case 4: return "Mild"
        case 5: return "Minimal"
        default: return ""
        }
    }
    
    func loadDailyLog(for date: Date) {
        if let log = dataManager.getDailyLog(for: date) {
            didVape = log.didVape
            moodScore = Int(log.moodScore)
            energyScore = Int(log.energyScore)
            sleepScore = Int(log.sleepScore)
            cravingsScore = Int(log.cravingsScore)
            notes = log.notes ?? ""
        }
    }
    
    func saveDailyLog(for date: Date) {
        _ = dataManager.saveDailyLog(
            date: date,
            didVape: didVape,
            moodScore: moodScore,
            energyScore: energyScore,
            sleepScore: sleepScore,
            cravingsScore: cravingsScore,
            notes: notes.isEmpty ? nil : notes
        )
    }
} 