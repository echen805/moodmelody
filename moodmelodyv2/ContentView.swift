import SwiftUI
import MusicKit

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasMusicAuthorization") private var hasMusicAuthorization = false
    @AppStorage("allowMockData") private var allowMockData = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding && hasMusicAuthorization {
                MoodInputView()
            } else if hasCompletedOnboarding && !hasMusicAuthorization {
                MusicAuthorizationView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MusicAuthorizationView: View {
    @AppStorage("hasMusicAuthorization") private var hasMusicAuthorization = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Apple Music Required")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("MoodMelody needs access to Apple Music to search for songs that match your mood.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if isLoading {
                ProgressView("Requesting access...")
                    .tint(.blue)
            } else {
                Button {
                    requestMusicAuthorization()
                } label: {
                    Text("Grant Apple Music Access")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding()
        .alert("Authorization Required", isPresented: $showError) {
            Button("Open Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Try Again", role: .none) {
                requestMusicAuthorization()
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func requestMusicAuthorization() {
        isLoading = true
        
        print(" [Authorization] Requesting Apple Music authorization...")
        print(" [Authorization] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print(" [Authorization] Current status: \(MusicAuthorization.currentStatus)")
        
        Task {
            let status = await MusicAuthorization.request()
            
            await MainActor.run {
                isLoading = false
                print(" [Authorization] Request result: \(status)")
                
                switch status {
                case .authorized:
                    print(" [Authorization] Successfully authorized!")
                    hasMusicAuthorization = true
                case .denied:
                    print(" [Authorization] User denied access")
                    showError(message: "Apple Music access is required for MoodMelody to work. Please enable it in Settings under Privacy & Security > Apple Music.")
                case .restricted:
                    print(" [Authorization] Access restricted by device settings")
                    showError(message: "Apple Music access is restricted on this device. Please check your device settings or parental controls.")
                case .notDetermined:
                    print(" [Authorization] Status still not determined after request")
                    showError(message: "Unable to access Apple Music. Please try again or check your device settings.")
                @unknown default:
                    print(" [Authorization] Unknown authorization status: \(status)")
                    showError(message: "An unknown error occurred while accessing Apple Music. Please try again.")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}