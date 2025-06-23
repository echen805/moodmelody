import Foundation
import MusicKit

@MainActor
class AppleMusicSearch: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    static let shared = AppleMusicSearch()
    
    private init() {}
    
    func searchTracks(for mood: MoodType, limit: Int = 10) async -> [Track] {
        // Check cache first
        if let cachedTracks = MoodCache.shared.getCachedTracks(for: mood) {
            print("Using cached tracks for \(mood.rawValue)")
            return cachedTracks
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var searchRequest = MusicCatalogSearchRequest(
                term: mood.searchTerm,
                types: [Song.self]
            )
            searchRequest.limit = limit
            
            let response = try await searchRequest.response()
            let songs = response.songs
            
            let tracks = songs.map { song in
                Track(
                    id: song.id.rawValue,
                    title: song.title,
                    artist: song.artistName,
                    artworkURL: song.artwork?.url(width: 300, height: 300),
                    previewURL: song.previewAssets?.first?.url,
                    catalogID: song.id.rawValue
                )
            }
            
            // Cache the results
            MoodCache.shared.cacheTracks(tracks, for: mood)
            
            isLoading = false
            return tracks
            
        } catch {
            errorMessage = "Failed to search tracks: \(error.localizedDescription)"
            isLoading = false
            print("Search error: \(error)")
            return []
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
