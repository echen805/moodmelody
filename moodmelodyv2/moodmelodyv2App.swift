import SwiftUI

@main
struct moodmelodyv2App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            // Temporarily bypass onboarding for testing
            MoodInputView()
            
            // Original logic:
            // if hasCompletedOnboarding {
            //     MoodInputView()
            // } else {
            //     OnboardingView()
            // }
        }
    }
}