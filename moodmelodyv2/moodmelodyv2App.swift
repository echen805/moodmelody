import SwiftUI
import MusicKit

@main
struct moodmelodyv2App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasMusicAuthorization") private var hasMusicAuthorization = false
    
    init() {
        // Initialize MusicKit configuration
        configureMusicKit()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Request authorization on launch
                    await requestMusicAuthorization()
                    clearAllCaches() // Clear caches on app start during development
                }
        }
    }
    
    private func configureMusicKit() {
        #if DEBUG
        if let bundleId = Bundle.main.bundleIdentifier {
            print("🎵 [App] Bundle ID: \(bundleId)")
        }
        if let teamId = Bundle.main.object(forInfoDictionaryKey: "DEVELOPMENT_TEAM") as? String {
            print("🎵 [App] Team ID: \(teamId)")
        }
        #endif
    }
    
    private func requestMusicAuthorization() async {
        print("🚀 [App] MoodMelody starting...")
        print("🚀 [App] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("🚀 [App] Onboarding completed: \(hasCompletedOnboarding)")
        print("🚀 [App] Current Music authorization: \(hasMusicAuthorization)")
        
        // Request authorization if needed
        let status = await MusicAuthorization.request()
        print("🔐 [App] Music Authorization Status: \(status)")
        
        // Update stored status
        await MainActor.run {
            hasMusicAuthorization = (status == .authorized)
        }
        
        // MusicKit is properly configured when authorization is granted
        print("✅ [App] MusicKit authorization completed")
    }
    
    private func clearAllCaches() {
        print("🧹 [App] Clearing all mood caches...")
        MoodType.allCases.forEach { mood in
            MoodCache.shared.clearCache(for: mood)
            print("🧹 [App] Cleared cache for mood: \(mood.rawValue)")
        }
    }
}