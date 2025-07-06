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
            let tracks: [Track]
            
            if SimulatorDetector.isSimulator {
                // Mock tracks for simulator
                tracks = generateMockTracks(for: mood, limit: limit)
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                print("Simulator: Generated \(tracks.count) mock tracks for \(mood.rawValue)")
            } else {
                // Real API call for device
                var searchRequest = MusicCatalogSearchRequest(
                    term: mood.searchTerm,
                    types: [Song.self]
                )
                searchRequest.limit = limit
                
                let response = try await searchRequest.response()
                let songs = response.songs
                
                tracks = songs.map { song in
                    Track(
                        id: song.id.rawValue,
                        title: song.title,
                        artist: song.artistName,
                        artworkURL: song.artwork?.url(width: 300, height: 300),
                        previewURL: song.previewAssets?.first?.url,
                        catalogID: song.id.rawValue
                    )
                }
                
                print("Device: Fetched \(tracks.count) tracks for \(mood.rawValue)")
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
    
    private func generateMockTracks(for mood: MoodType, limit: Int) -> [Track] {
        let mockData: [MoodType: [(title: String, artist: String)]] = [
            .happy: [
                ("Happy", "Pharrell Williams"),
                ("Good as Hell", "Lizzo"),
                ("Uptown Funk", "Mark Ronson ft. Bruno Mars"),
                ("Can't Stop the Feeling!", "Justin Timberlake"),
                ("Walking on Sunshine", "Katrina and the Waves"),
                ("I Gotta Feeling", "The Black Eyed Peas"),
                ("September", "Earth, Wind & Fire"),
                ("Good Vibrations", "The Beach Boys"),
                ("Mr. Blue Sky", "Electric Light Orchestra"),
                ("Dancing Queen", "ABBA")
            ],
            .sad: [
                ("Someone Like You", "Adele"),
                ("Hurt", "Johnny Cash"),
                ("Mad World", "Gary Jules"),
                ("Black", "Pearl Jam"),
                ("Everybody Hurts", "R.E.M."),
                ("Tears in Heaven", "Eric Clapton"),
                ("The Night We Met", "Lord Huron"),
                ("Skinny Love", "Bon Iver"),
                ("Hallelujah", "Jeff Buckley"),
                ("Fix You", "Coldplay")
            ],
            .angry: [
                ("Break Stuff", "Limp Bizkit"),
                ("Bodies", "Drowning Pool"),
                ("Killing in the Name", "Rage Against the Machine"),
                ("Chop Suey!", "System of a Down"),
                ("The Beautiful People", "Marilyn Manson"),
                ("Toxicity", "System of a Down"),
                ("Du Hast", "Rammstein"),
                ("Freak on a Leash", "Korn"),
                ("One Step Closer", "Linkin Park"),
                ("Sabotage", "Beastie Boys")
            ],
            .frustrated: [
                ("In the End", "Linkin Park"),
                ("Numb", "Linkin Park"),
                ("Crawling", "Linkin Park"),
                ("Heavy", "Linkin Park ft. Kiiara"),
                ("Boulevard of Broken Dreams", "Green Day"),
                ("Hurt", "Nine Inch Nails"),
                ("Breaking the Habit", "Linkin Park"),
                ("Somewhere I Belong", "Linkin Park"),
                ("Papercut", "Linkin Park"),
                ("Points of Authority", "Linkin Park")
            ]
        ]
        
        let moodTracks = mockData[mood] ?? mockData[.happy]!
        let limitedTracks = Array(moodTracks.prefix(limit))
        
        return limitedTracks.enumerated().map { index, trackData in
            Track(
                id: "\(mood.rawValue)-mock-\(index)",
                title: trackData.title,
                artist: trackData.artist,
                artworkURL: nil, // No artwork for mock data
                previewURL: nil, // No preview for mock data
                catalogID: "\(mood.rawValue)-mock-\(index)"
            )
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}