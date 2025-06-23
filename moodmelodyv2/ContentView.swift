import SwiftUI
import MusicKit

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MoodSelectorView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
