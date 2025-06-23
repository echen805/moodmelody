import Foundation
import AVFoundation

@MainActor
class AppleMusicPlayback: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    static let shared = AppleMusicPlayback()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playPreview(track: Track) {
        guard let previewURL = track.previewURL else {
            print("No preview URL available for track: \(track.title)")
            return
        }
        
        // Stop current playback
        stop()
        
        // Create new player item and player
        playerItem = AVPlayerItem(url: previewURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe playback status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Start playback
        player?.play()
        currentTrack = track
        isPlaying = true
        
        print("Playing preview for: \(track.title)")
    }
    
    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        currentTrack = nil
        isPlaying = false
        
        // Remove observers
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    func togglePlayback() {
        if isPlaying {
            stop()
        } else if let track = currentTrack {
            playPreview(track: track)
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.stop()
        }
    }
    
    deinit {
        Task { @MainActor in
            stop()
        }
    }
}
