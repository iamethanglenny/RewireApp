import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    private let dataManager = DataManager.shared
    
    @Published var dailyVapingCost: Double = 0.0
    @Published var quitDate: Date = Date()
    @Published var showResetConfirmation = false
    @Published var showExportSuccess = false
    
    var quitDateFormatted: String {
        if let _ = dataManager.getUserSettings()?.quitDate {
            return quitDate.formattedString(style: .medium)
        } else {
            return "Not set"
        }
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let settings = dataManager.getUserSettings() {
            dailyVapingCost = settings.dailyVapingCost
            if let date = settings.quitDate {
                quitDate = date
            }
        }
    }
    
    func saveSettings() {
        _ = dataManager.saveUserSettings(dailyVapingCost: dailyVapingCost, quitDate: quitDate)
    }
    
    func resetAllData() {
        // This would need to be implemented to delete all Core Data records
        // For now, we'll just reset the settings
        _ = dataManager.saveUserSettings(dailyVapingCost: 0.0, quitDate: nil)
        loadSettings()
    }
    
    func exportData() {
        // This would need to be implemented to export data to a file
        // For now, we'll just show a success message
        showExportSuccess = true
    }
} 