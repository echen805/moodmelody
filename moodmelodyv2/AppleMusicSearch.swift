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
            print("✅ [MusicSearch] Using cached tracks for \(mood.rawValue)")
            return cachedTracks
        }
        
        isLoading = true
        errorMessage = nil
        
        // Log detailed attempt information for developers
        print("🎵 [MusicSearch] Starting search for mood: \(mood.rawValue)")
        print("🎵 [MusicSearch] Search term: '\(mood.searchTerm)'")
        print("🎵 [MusicSearch] Limit: \(limit)")
        print("🎵 [MusicSearch] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        
        do {
            let tracks: [Track]
            
            if SimulatorDetector.isSimulator {
                // Only use mock data in simulator
                print("📱 [MusicSearch] Running in simulator - using mock data")
                tracks = generateMockTracks(for: mood, limit: limit)
                try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
            } else {
                // Real device: attempt real API access
                print("📱 [MusicSearch] Running on device - attempting real Apple Music API")
                
                // Check authorization first
                let authStatus = MusicAuthorization.currentStatus
                print("🔐 [MusicSearch] Current authorization status: \(authStatus)")
                
                if authStatus != .authorized {
                    print("🔐 [MusicSearch] Authorization required, requesting...")
                    let requestedStatus = await MusicAuthorization.request()
                    print("🔐 [MusicSearch] Authorization result: \(requestedStatus)")
                    
                    if requestedStatus != .authorized {
                        let error = MusicError.authorizationNotGranted
                        errorMessage = "Apple Music access is required to search for tracks."
                        print("❌ [MusicSearch] Authorization denied by user")
                        isLoading = false
                        return []
                    }
                }
                
                print("✅ [MusicSearch] Authorization granted, making API request...")
                
                // Make the real API call
                var searchRequest = MusicCatalogSearchRequest(
                    term: mood.searchTerm,
                    types: [Song.self]
                )
                searchRequest.limit = limit
                
                print("🌐 [MusicSearch] API Request configured: \(mood.searchTerm)")
                
                let response = try await searchRequest.response()
                let songs = response.songs
                
                print("✅ [MusicSearch] API Response received: \(songs.count) songs")
                
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
                
                print("🎵 [MusicSearch] Successfully converted \(tracks.count) songs to Track objects")
                
                // Log first few track names for debugging
                for (index, track) in tracks.prefix(3).enumerated() {
                    print("🎵 [MusicSearch] Track \(index + 1): '\(track.title)' by \(track.artist)")
                }
            }
            
            // Cache the results
            MoodCache.shared.cacheTracks(tracks, for: mood)
            print("💾 [MusicSearch] Cached \(tracks.count) tracks for \(mood.rawValue)")
            
            isLoading = false
            return tracks
            
        } catch {
            // Detailed error logging for developers
            print("❌ [MusicSearch] Search failed with error:")
            print("❌ [MusicSearch] Error type: \(type(of: error))")
            print("❌ [MusicSearch] Error description: \(error.localizedDescription)")
            print("❌ [MusicSearch] Full error: \(error)")
            
            // Set user-friendly error message based on error type
            if let nsError = error as NSError? {
                print("❌ [MusicSearch] NSError domain: \(nsError.domain)")
                print("❌ [MusicSearch] NSError code: \(nsError.code)")
                print("❌ [MusicSearch] NSError userInfo: \(nsError.userInfo)")
                
                // Provide specific developer guidance based on common errors
                switch nsError.domain {
                case "ICError":
                    if nsError.code == -8200 {
                        print("🛠️  [MusicSearch] DEVELOPER FIX NEEDED:")
                        print("🛠️  [MusicSearch] This is a MusicKit token error (-8200)")
                        print("🛠️  [MusicSearch] Bundle ID '\(Bundle.main.bundleIdentifier ?? "Unknown")' is not registered with Apple Music API")
                        print("🛠️  [MusicSearch] To fix:")
                        print("🛠️  [MusicSearch]   1. Go to https://developer.apple.com")
                        print("🛠️  [MusicSearch]   2. Navigate to Certificates, Identifiers & Profiles")
                        print("🛠️  [MusicSearch]   3. Create/update App ID with MusicKit enabled")
                        print("🛠️  [MusicSearch]   4. Ensure bundle ID matches exactly")
                        errorMessage = "Apple Music is not available right now. Please try again later."
                    } else {
                        print("🛠️  [MusicSearch] ICError with code \(nsError.code) - check Apple Developer documentation")
                        errorMessage = "Unable to connect to Apple Music. Please check your internet connection."
                    }
                case "MusicKitErrorDomain":
                    print("🛠️  [MusicSearch] MusicKit specific error - check MusicKit documentation")
                    errorMessage = "Apple Music service is temporarily unavailable. Please try again."
                case "NSURLErrorDomain":
                    print("🛠️  [MusicSearch] Network error - user's internet connection issue")
                    errorMessage = "Please check your internet connection and try again."
                default:
                    print("🛠️  [MusicSearch] Unknown error domain: \(nsError.domain)")
                    errorMessage = "Unable to search Apple Music. Please try again later."
                }
            } else {
                // Generic error handling
                errorMessage = "Unable to search Apple Music. Please check your connection and try again."
            }
            
            isLoading = false
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
            ],
            .calm: [
                ("Weightless", "Marconi Union"),
                ("Clair de Lune", "Claude Debussy"),
                ("Mad World", "Gary Jules"),
                ("The Night We Met", "Lord Huron"),
                ("Holocene", "Bon Iver"),
                ("River", "Joni Mitchell"),
                ("Gymnopédie No. 1", "Erik Satie"),
                ("Spiegel im Spiegel", "Arvo Pärt"),
                ("On Earth as It Is in Heaven", "Angel Olsen"),
                ("Peace Piece", "Bill Evans")
            ],
            .energetic: [
                ("Thunder", "Imagine Dragons"),
                ("Uptown Funk", "Mark Ronson ft. Bruno Mars"),
                ("Can't Stop the Feeling!", "Justin Timberlake"),
                ("Shut Up and Dance", "Walk the Moon"),
                ("I Gotta Feeling", "The Black Eyed Peas"),
                ("Pump It", "The Black Eyed Peas"),
                ("Stronger", "Kanye West"),
                ("Eye of the Tiger", "Survivor"),
                ("We Will Rock You", "Queen"),
                ("Don't Stop Believin'", "Journey")
            ],
            .nostalgic: [
                ("The Way You Look Tonight", "Tony Bennett"),
                ("Dream a Little Dream of Me", "Ella Fitzgerald"),
                ("La Vie En Rose", "Édith Piaf"),
                ("At Last", "Etta James"),
                ("Fly Me to the Moon", "Frank Sinatra"),
                ("What a Wonderful World", "Louis Armstrong"),
                ("The Girl from Ipanema", "Stan Getz & João Gilberto"),
                ("Summertime", "Billie Holiday"),
                ("Blue Moon", "Frank Sinatra"),
                ("Autumn Leaves", "Nat King Cole")
            ],
            .romantic: [
                ("All of Me", "John Legend"),
                ("Perfect", "Ed Sheeran"),
                ("Thinking Out Loud", "Ed Sheeran"),
                ("A Thousand Years", "Christina Perri"),
                ("Make You Feel My Love", "Adele"),
                ("At Last", "Etta James"),
                ("The Way You Look Tonight", "Tony Bennett"),
                ("L-O-V-E", "Nat King Cole"),
                ("La Vie En Rose", "Édith Piaf"),
                ("Dream a Little Dream of Me", "Ella Fitzgerald")
            ],
            .melancholic: [
                ("Mad World", "Gary Jules"),
                ("Hurt", "Johnny Cash"),
                ("Black", "Pearl Jam"),
                ("The Sound of Silence", "Simon & Garfunkel"),
                ("Everybody Hurts", "R.E.M."),
                ("Creep", "Radiohead"),
                ("Hallelujah", "Jeff Buckley"),
                ("The Night We Met", "Lord Huron"),
                ("Skinny Love", "Bon Iver"),
                ("Holocene", "Bon Iver")
            ],
            .excited: [
                ("Happy", "Pharrell Williams"),
                ("Can't Stop the Feeling!", "Justin Timberlake"),
                ("Uptown Funk", "Mark Ronson ft. Bruno Mars"),
                ("I Gotta Feeling", "The Black Eyed Peas"),
                ("Good as Hell", "Lizzo"),
                ("Shut Up and Dance", "Walk the Moon"),
                ("Walking on Sunshine", "Katrina and the Waves"),
                ("September", "Earth, Wind & Fire"),
                ("Dancing Queen", "ABBA"),
                ("Mr. Blue Sky", "Electric Light Orchestra")
            ]
        ]
        
        // Handle custom moods and fallback
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

enum MusicError: Error, LocalizedError {
    case authorizationNotGranted
    
    var errorDescription: String? {
        switch self {
        case .authorizationNotGranted:
            return "Apple Music authorization not granted"
        }
    }
}