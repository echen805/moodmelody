import SwiftUI

@main
struct moodmelodyv2App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MoodSelectorView()
            } else {
                OnboardingView()
            }
        }
    }
}
