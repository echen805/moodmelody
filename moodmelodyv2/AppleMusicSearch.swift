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
        
        return await searchTracks(for: mood.searchTerm(), limit: limit)
    }
    
    func searchTracks(for searchTerm: String, limit: Int = 10) async -> [Track] {
        
        isLoading = true
        errorMessage = nil
        
        // Log detailed attempt information for developers
        print("🎵 [MusicSearch] Starting search for term: '\(searchTerm)'")
        print("🎵 [MusicSearch] Limit: \(limit)")
        print("🎵 [MusicSearch] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        
        do {
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
            
            // Create search request
            var searchRequest = MusicCatalogSearchRequest(
                term: searchTerm,
                types: [Song.self]
            )
            searchRequest.limit = limit
            
            print("🌐 [MusicSearch] API Request configured: \(searchTerm)")
            
            let response = try await searchRequest.response()
            let songs = response.songs
            
            print("✅ [MusicSearch] API Response received: \(songs.count) songs")
            
            let tracks = songs.compactMap { song -> Track? in
                // Only include songs that have preview assets
                guard let previewURL = song.previewAssets?.first?.url else {
                    print("⚠️ [MusicSearch] Skipping song without preview: \(song.title)")
                    return nil
                }
                
                return Track(
                    id: song.id.rawValue,
                    title: song.title,
                    artist: song.artistName,
                    artworkURL: song.artwork?.url(width: 300, height: 300),
                    previewURL: previewURL,
                    catalogID: song.id.rawValue
                )
            }
            
            print("🎵 [MusicSearch] Successfully converted \(tracks.count) songs to Track objects")
            
            // Log first few track names for debugging
            for (index, track) in tracks.prefix(3).enumerated() {
                print("🎵 [MusicSearch] Track \(index + 1): '\(track.title)' by \(track.artist)")
            }
            
            // Cache the results (only for mood-based searches)
            if !tracks.isEmpty {
                // For custom search terms, we don't cache as they're dynamic
                print("💾 [MusicSearch] Found \(tracks.count) tracks for search term: '\(searchTerm)'")
            } else {
                print("⚠️ [MusicSearch] No tracks found for search term: '\(searchTerm)'")
                errorMessage = "No tracks found for this search. Please try again."
            }
            
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
        // Define a type for our enhanced mock data
        struct MockTrack {
            let title: String
            let artist: String
            let previewURL: String?
            let artworkURL: String?
        }
        
        // Updated mock data with preview URLs
        let mockData: [MoodType: [MockTrack]] = [
            .happy: [
                MockTrack(
                    title: "Happy",
                    artist: "Pharrell Williams",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/7b/28/95/7b289597-8746-3e6a-8c1f-51fdf52ce3c7/mzaf_8986637503086299997.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/f1/cc/69/f1cc69f8-8be4-b7ea-99c2-98dda35396da/886444727747.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Good as Hell",
                    artist: "Lizzo",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/42/de/cf/42decfb4-0c3a-809c-779a-f431e8f8e615/mzaf_15279441328251258695.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/44/fd/67/44fd67c0-7c7c-96aa-7904-56f53f385118/075679842275.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Uptown Funk",
                    artist: "Mark Ronson ft. Bruno Mars",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/d9/c8/c3/d9c8c345-f852-fd5a-271e-08ce08cdf4a3/mzaf_16524191704489572135.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/35/fd/01/35fd012f-a54c-0a5d-0bf3-c61fc66a72a2/886444955843.jpg/400x400bb.jpg"
                )
            ],
            .calm: [
                MockTrack(
                    title: "Weightless",
                    artist: "Marconi Union",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/46/d1/8c/46d18c44-2c08-c03d-8d2d-4c82aa813b1d/mzaf_13299827868733339400.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/46/e1/d3/46e1d354-97ea-b523-3d16-4638eae93f1c/859726462655_cover.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Clair de Lune",
                    artist: "Claude Debussy",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/96/29/6e/96296e23-d102-c0f7-34b8-d8f0b9f17dbb/mzaf_15001752423346772040.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/7c/8c/fa/7c8cfa3d-9f36-ac89-c7db-dfdd6f436100/20UMGIM85432.rgb.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "River Flows In You",
                    artist: "Yiruma",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/93/06/ec/9306ec5d-7fce-5cfe-fb6d-ddf916920632/mzaf_8546915963288627725.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/6e/29/ea/6e29ea02-2577-7d19-d501-24c805a63324/191018894421.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Gymnopédie No. 1",
                    artist: "Erik Satie",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/32/39/e4/3239e459-1b37-e4bb-48ae-b21aa1e52127/mzaf_18437633248411199823.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/21/08/2f/21082f76-8e10-4683-c21b-290ee7a0ec8c/21UMGIM47176.rgb.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Spiegel im Spiegel",
                    artist: "Arvo Pärt",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/98/8c/cb/988ccb97-a067-4282-c7c9-9a5e61d81401/mzaf_5987177512622064167.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/6e/29/ea/6e29ea02-2577-7d19-d501-24c805a63324/191018894421.jpg/400x400bb.jpg"
                ),
                MockTrack(
                    title: "Peaceful Piano",
                    artist: "Joep Beving",
                    previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/d9/5f/66/d95f66d6-3b88-9f0d-1c3f-52747d77eef5/mzaf_12363936653500120931.plus.aac.p.m4a",
                    artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/7d/dd/7f/7ddd7f4f-05d5-e0cb-e4c5-f5e93c15f769/20UMGIM03994.rgb.jpg/400x400bb.jpg"
                )
            ]
        ]
        
        // Use a fallback preview URL for moods without specific mock data
        let fallbackPreviewURL = "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/8c/66/03/8c660365-daa6-6b5d-8280-8e521026d01d/mzaf_4818400418435025827.plus.aac.p.m4a"
        let fallbackArtworkURL = "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/7f/52/86/7f5286d5-4ef9-b0be-8597-f9653c251fc8/886444381390.jpg/400x400bb.jpg"
        
        // Get tracks for the mood, or use happy tracks as fallback
        let moodTracks = mockData[mood] ?? mockData[.happy] ?? []
        let limitedTracks = Array(moodTracks.prefix(limit))
        
        return limitedTracks.enumerated().map { index, trackData in
            Track(
                id: "\(mood.rawValue)-mock-\(index)",
                title: trackData.title,
                artist: trackData.artist,
                artworkURL: URL(string: trackData.artworkURL ?? fallbackArtworkURL),
                previewURL: URL(string: trackData.previewURL ?? fallbackPreviewURL),
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