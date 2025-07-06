import Foundation
import AVFoundation

@MainActor
class AppleMusicPlayback: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var mockPlaybackTimer: Timer?
    
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
        if SimulatorDetector.isSimulator {
            // Mock playback for simulator
            playMockPreview(track: track)
        } else {
            // Real playback for device
            playRealPreview(track: track)
        }
    }
    
    private func playMockPreview(track: Track) {
        // Stop current playback
        stop()
        
        // Start mock playback
        currentTrack = track
        isPlaying = true
        
        print("Mock playing: \(track.title) by \(track.artist)")
        
        // Simulate 30-second preview
        mockPlaybackTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
            Task { @MainActor in
                self.stop()
            }
        }
    }
    
    private func playRealPreview(track: Track) {
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
        // Stop real playback
        player?.pause()
        player = nil
        playerItem = nil
        
        // Stop mock playback
        mockPlaybackTimer?.invalidate()
        mockPlaybackTimer = nil
        
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