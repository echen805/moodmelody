import Foundation
import MusicKit
import MoodCore

@MainActor
public class AppleMusicSearch: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    public static let shared = AppleMusicSearch()
    
    private init() {}
    
    public func searchTracks(for mood: MoodType, limit: Int = 10) async -> [Track] {
        // Check cache first
        if let cachedTracks = MoodCache.shared.getCachedTracks(for: mood) {
            print("Using cached tracks for \(mood.rawValue)")
            return cachedTracks
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let searchRequest = MusicCatalogSearchRequest(
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
    
    public func clearError() {
        errorMessage = nil
    }
}