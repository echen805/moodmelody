import Foundation
import MusicKit

@MainActor
class AppleMusicPlayback: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    
    static let shared = AppleMusicPlayback()
    
    private override init() {
        super.init()
    }
    
    func playSong(track: Track) {
        guard let catalogID = track.catalogID else {
            print("❌ [Playback] No catalog ID for track: \(track.title)")
            return
        }
        
        // Check if running in simulator
        #if targetEnvironment(simulator)
        print("⚠️ [Playback] Apple Music playback is not available in simulator")
        print("⚠️ [Playback] Would play: \(track.title) by \(track.artist) (ID: \(catalogID))")
        // Simulate successful playback for UI testing
        currentTrack = track
        isPlaying = true
        return
        #endif
        
        Task {
            do {
                let song = try await MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(catalogID)).response().items.first
                guard let song = song else {
                    print("❌ [Playback] Could not fetch song for catalog ID: \(catalogID)")
                    return
                }
                let player = ApplicationMusicPlayer.shared
                player.queue = [song]
                try await player.play()
                await MainActor.run {
                    self.currentTrack = track
                    self.isPlaying = true
                }
                print("✅ [Playback] Now playing full song: \(track.title) by \(track.artist)")
            } catch {
                print("❌ [Playback] Failed to play song: \(error)")
                // Reset state on error
                currentTrack = nil
                isPlaying = false
            }
        }
    }
    
    func stop() {
        #if targetEnvironment(simulator)
        print("⚠️ [Playback] Stopping simulated playback")
        #else
        let player = ApplicationMusicPlayer.shared
        player.stop()
        #endif
        
        currentTrack = nil
        isPlaying = false
        print("✅ [Playback] Playback stopped")
    }
    
    func togglePlayback() {
        if isPlaying {
            stop()
        } else if let track = currentTrack {
            playSong(track: track)
        }
    }
}