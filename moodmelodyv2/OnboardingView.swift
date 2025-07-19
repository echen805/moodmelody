import SwiftUI
import MusicKit

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isLoading = true
    @State private var isAuthorized = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                        
                        Text("MoodMelody")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Discover music that matches your mood")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        ProgressView("Checking Apple Music access...")
                            .tint(.blue)
                        
                        Text("We need access to Apple Music to provide personalized recommendations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding()
            } else if isAuthorized {
                // User is authorized, proceed to main app
                ContentView()
            } else {
                // User needs to authorize
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                        
                        Text("MoodMelody")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Discover music that matches your mood")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button {
                            requestAppleMusicAuthorization()
                        } label: {
                            HStack {
                                Image(systemName: "music.note")
                                    .font(.headline)
                                Text("Continue with Apple Music")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Connect to Apple Music")
                        .accessibilityHint("Double tap to request Apple Music authorization")
                        
                        Text("We need access to Apple Music to provide personalized recommendations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .alert("Authorization Error", isPresented: $showError) {
            Button("Open Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await checkMusicAuthorization()
        }
    }
    
    private func checkMusicAuthorization() async {
        print("🔍 [Onboarding] Checking Apple Music authorization status...")
        
        let status = MusicAuthorization.currentStatus
        print("🔍 [Onboarding] Current status: \(status)")
        
        await MainActor.run {
            isLoading = false
            isAuthorized = (status == .authorized)
            
            if isAuthorized {
                print("✅ [Onboarding] User already authorized, proceeding to main app")
                hasCompletedOnboarding = true
            } else {
                print("⚠️ [Onboarding] User not authorized, showing authorization prompt")
            }
        }
    }
    
    private func requestAppleMusicAuthorization() {
        print("🔐 [Onboarding] Requesting Apple Music authorization...")
        
        Task {
            do {
                let status = await MusicAuthorization.request()
                print("🔐 [Onboarding] Authorization result: \(status)")
                
                await MainActor.run {
                    switch status {
                    case .authorized:
                        print("✅ [Onboarding] Successfully authorized Apple Music")
                        isAuthorized = true
                        hasCompletedOnboarding = true
                    case .denied:
                        showError(message: "Please enable Apple Music access in Settings to use MoodMelody.")
                    case .restricted:
                        showError(message: "Apple Music access is restricted on this device. Please check your device settings.")
                    case .notDetermined:
                        showError(message: "Unable to access Apple Music. Please try again.")
                    @unknown default:
                        showError(message: "An unknown error occurred while accessing Apple Music.")
                    }
                }
            } catch {
                await MainActor.run {
                    showError(message: "Failed to connect to Apple Music: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
