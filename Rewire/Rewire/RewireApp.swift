//
//  RewireApp.swift
//  Rewire
//
//  Created by Ethan Glenny on 2025/03/11.
//

import SwiftUI
import Combine

// We need to make sure the Storage directory is added to the Xcode project target
// This can be done in Xcode by:
// 1. Right-click in the Project Navigator
// 2. Select "Add Files to 'Rewire'..."
// 3. Navigate to and select the Storage directory
// 4. Ensure "Copy items if needed" is unchecked
// 5. Make sure your main app target is selected
// 6. Click "Add"

@main
struct RewireApp: App {
    // Use the AppState from the Storage directory
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.userViewModel)
                .environmentObject(appState.challengeViewModel)
                .environmentObject(appState.trackingViewModel)
                .onAppear {
                    // Update recovery progress when app launches
                    appState.updateRecoveryProgress()
                }
        }
    }
}
