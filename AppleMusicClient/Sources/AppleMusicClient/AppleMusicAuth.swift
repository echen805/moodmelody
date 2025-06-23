import Foundation
import MusicKit
import MoodCore

@MainActor
public class AppleMusicAuth: ObservableObject {
    @Published public var authorizationStatus: MusicAuthorization.Status = .notDetermined
    @Published public var isAuthorized: Bool = false
    
    public static let shared = AppleMusicAuth()
    
    private init() {
        updateAuthorizationStatus()
    }
    
    public func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        updateAuthorizationStatus()
    }
    
    private func updateAuthorizationStatus() {
        authorizationStatus = MusicAuthorization.currentStatus
        isAuthorized = authorizationStatus == .authorized
    }
    
    public func checkAuthorizationStatus() {
        updateAuthorizationStatus()
    }
}