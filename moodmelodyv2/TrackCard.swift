import SwiftUI

struct TrackCard: View {
    @State private var track: Track
    let mood: MoodType
    let onLikeToggle: (Track) -> Void
    
    @StateObject private var playback = AppleMusicPlayback.shared
    
    init(track: Track, mood: MoodType, onLikeToggle: @escaping (Track) -> Void) {
        self._track = State(initialValue: track)
        self.mood = mood
        self.onLikeToggle = onLikeToggle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Artwork
            AsyncImage(url: track.artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 16) {
                // Play/Pause Button
                Button {
                    if playback.currentTrack?.id == track.id && playback.isPlaying {
                        playback.stop()
                    } else {
                        playback.playSong(track: track)
                    }
                } label: {
                    Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                // Like Button
                Button {
                    track = track.toggleLike()
                    MoodCache.shared.toggleLike(trackID: track.id, for: mood)
                    onLikeToggle(track)
                } label: {
                    Image(systemName: track.isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(track.isLiked ? .red : .gray)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            // Update like status from cache
            track.isLiked = MoodCache.shared.isLiked(trackID: track.id, for: mood)
        }
    }
    
    private var isCurrentlyPlaying: Bool {
        playback.currentTrack?.id == track.id && playback.isPlaying
    }
}