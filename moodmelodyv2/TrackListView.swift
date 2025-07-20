import SwiftUI

struct TrackListView: View {
    let mood: MoodType?
    let intensity: MoodIntensity?
    let fusion: MoodFusion?
    let originalInput: String
    let sessionId: String
    
    @State private var tracks: [Track] = []
    @State private var allTracks: [Track] = [] // Full 30-song playlist
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingMoodSelector = false
    @State private var showingAllTracks = false
    
    @StateObject private var searchClient = AppleMusicSearch.shared
    @StateObject private var cache = MoodCache.shared
    @StateObject private var feedbackManager = FeedbackManager.shared
    
    @Environment(\.dismiss) private var dismiss
    
    // Computed properties for display
    private var displayMood: MoodType {
        return mood ?? fusion?.primaryMood ?? .happy
    }
    
    private var searchTerm: String {
        if let fusion = fusion {
            return fusion.searchTerm
        } else if let mood = mood {
            return mood.enhancedSearchTerm(with: intensity)
        }
        return "music"
    }
    
    private var displayName: String {
        if let fusion = fusion {
            return fusion.displayName
        } else if let mood = mood {
            if let intensity = intensity {
                return "\(intensity.rawValue.capitalized) \(mood.rawValue)"
            }
            return mood.rawValue
        }
        return "Music"
    }
    
    private var displayEmoji: String {
        if let fusion = fusion {
            return fusion.emoji
        } else if let mood = mood {
            return mood.emoji
        }
        return "🎵"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content
                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Finding \(displayName.lowercased()) music...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if let error = errorMessage {
                    // Enhanced error display
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Unable to Find Music")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button("Try Again") {
                                loadTracks()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Try Different Mood") {
                                showingMoodSelector = true
                            }
                            .buttonStyle(.bordered)
                        }
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
                        
                        Text("Try a different mood or search term")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            Button("Try Again") {
                                loadTracks()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Different Mood") {
                                showingMoodSelector = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Feedback Section
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Not quite what you're looking for?")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button("Different mood") {
                                        showingMoodSelector = true
                                    }
                                    .font(.caption)
                                    .buttonStyle(.borderless)
                                    .foregroundColor(.blue)
                                }
                                
                                Button("These results don't match my mood") {
                                    recordResultsNotGood()
                                }
                                .font(.caption)
                                .buttonStyle(.borderless)
                                .foregroundColor(.orange)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            ForEach(tracks) { track in
                                TrackCard(
                                    track: track,
                                    mood: displayMood,
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
                            
                            // Show All Tracks Button
                            if allTracks.count > tracks.count {
                                VStack(spacing: 12) {
                                    Divider()
                                        .padding(.horizontal)
                                    
                                    Button("Show All \(allTracks.count) Tracks") {
                                        showingAllTracks = true
                                    }
                                    .buttonStyle(.bordered)
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
            .navigationTitle("\(displayEmoji) \(displayName) Music")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        cache.clearCache(for: displayMood)
                        loadTracks()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadTracks()
            }
            .sheet(isPresented: $showingMoodSelector) {
                MoodSelectorSheet(
                    isPresented: $showingMoodSelector,
                    onMoodSelected: { correctedMood in
                        // Record the mood correction
                        feedbackManager.recordMoodCorrection(
                            originalInput: originalInput,
                            detectedMood: displayMood,
                            correctedMood: correctedMood,
                            sessionId: sessionId
                        )
                        
                        dismiss()
                    },
                    currentMood: displayMood
                )
            }
            .sheet(isPresented: $showingAllTracks) {
                AllTracksView(
                    tracks: allTracks,
                    mood: displayMood,
                    title: "\(displayEmoji) All \(displayName) Music"
                )
            }
        }
    }
    
    private func loadTracks() {
        isLoading = true
        errorMessage = nil
        
        // Log the attempt for developers
        print("🎵 [TrackListView] Loading tracks for: \(displayName)")
        print("🎵 [TrackListView] Search term: '\(searchTerm)'")
        print("🎵 [TrackListView] Original input: '\(originalInput)'")
        print("🎵 [TrackListView] Session ID: \(sessionId)")
        
        Task {
            let fetchedTracks: [Track]
            
            if let fusion = fusion {
                // Use fusion search term
                fetchedTracks = await searchClient.searchTracks(for: searchTerm, limit: 25)
            } else if let mood = mood {
                // Use enhanced mood search
                fetchedTracks = await searchClient.searchTracks(for: searchTerm, limit: 25)
            } else {
                // Fallback
                fetchedTracks = await searchClient.searchTracks(for: "music", limit: 25)
            }
            
            await MainActor.run {
                self.allTracks = fetchedTracks
                self.tracks = Array(fetchedTracks.prefix(10)) // Show first 10 tracks (max 25 total due to API limit)
                self.isLoading = false
                
                if let error = searchClient.errorMessage {
                    self.errorMessage = error
                    print("❌ [TrackListView] Received error from search client: \(error)")
                    searchClient.clearError()
                } else {
                    print("✅ [TrackListView] Successfully loaded \(fetchedTracks.count) tracks, showing 10")
                }
            }
        }
    }
    
    private func updateTrackInList(_ updatedTrack: Track) {
        if let index = tracks.firstIndex(where: { $0.id == updatedTrack.id }) {
            tracks[index] = updatedTrack
        }
    }
    
    private func recordResultsNotGood() {
        print("📊 [TrackListView] Recording negative feedback for: \(displayName)")
        feedbackManager.recordResultsNotGood(
            originalInput: originalInput,
            detectedMood: displayMood,
            sessionId: sessionId
        )
        
        // Show some feedback to user
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - AllTracksView
struct AllTracksView: View {
    let tracks: [Track]
    let mood: MoodType
    let title: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playback = AppleMusicPlayback.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(tracks) { track in
                            TrackCard(
                                track: track,
                                mood: mood,
                                onLikeToggle: { _ in
                                    // Handle like toggle if needed
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
                
                // Playback Bar
                PlaybackBar()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}