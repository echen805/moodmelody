import SwiftUI

struct TrackListView: View {
    let mood: MoodType
    
    @State private var tracks: [Track] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var searchClient = AppleMusicSearch.shared
    @StateObject private var cache = MoodCache.shared
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content
                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Finding \(mood.rawValue.lowercased()) music...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if tracks.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No tracks found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Try Again") {
                            loadTracks()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(tracks) { track in
                                TrackCard(
                                    track: track,
                                    mood: mood,
                                    onLikeToggle: { updatedTrack in
                                        updateTrackInList(updatedTrack)
                                    }
                                )
                                .padding(.horizontal)
                                
                                if track.id != tracks.last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                // Playback Bar
                PlaybackBar()
            }
            .navigationTitle("\(mood.emoji) \(mood.rawValue) Music")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        cache.clearCache(for: mood)
                        loadTracks()
                    }
                }
            }
            .onAppear {
                loadTracks()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func loadTracks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let fetchedTracks = await searchClient.searchTracks(for: mood, limit: 10)
            
            await MainActor.run {
                self.tracks = fetchedTracks
                self.isLoading = false
                
                if let error = searchClient.errorMessage {
                    self.errorMessage = error
                    searchClient.clearError()
                }
            }
        }
    }
    
    private func updateTrackInList(_ updatedTrack: Track) {
        if let index = tracks.firstIndex(where: { $0.id == updatedTrack.id }) {
            tracks[index] = updatedTrack
        }
    }
}
