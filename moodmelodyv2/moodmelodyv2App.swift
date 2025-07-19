import SwiftUI
import MusicKit

@main
struct moodmelodyv2App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasMusicAuthorization") private var hasMusicAuthorization = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkMusicAuthorization()
                }
        }
    }
    
    private func checkMusicAuthorization() {
        // Log app startup for developers
        print("🚀 [App] MoodMelody starting...")
        print("🚀 [App] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("🚀 [App] Onboarding completed: \(hasCompletedOnboarding)")
        print("🚀 [App] Music authorization stored: \(hasMusicAuthorization)")
        
        Task {
            let currentStatus = MusicAuthorization.currentStatus
            print("🔐 [App] Current MusicKit status: \(currentStatus)")
            
            await MainActor.run {
                // Update stored authorization status based on current reality
                let isActuallyAuthorized = (currentStatus == .authorized)
                if hasMusicAuthorization != isActuallyAuthorized {
                    print("🔄 [App] Updating stored authorization status from \(hasMusicAuthorization) to \(isActuallyAuthorized)")
                    hasMusicAuthorization = isActuallyAuthorized
                }
            }
        }
    }
}