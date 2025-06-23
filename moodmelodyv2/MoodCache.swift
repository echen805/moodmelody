import Foundation

@MainActor
class MoodCache: ObservableObject {
    static let shared = MoodCache()
    
    private let userDefaults = UserDefaults.standard
    private let cacheExpirationTime: TimeInterval = 24 * 60 * 60 // 24 hours
    
    private init() {}
    
    // MARK: - Cache Keys
    private func tracksKey(for mood: MoodType) -> String {
        return "cached_tracks_\(mood.rawValue)"
    }
    
    private func timestampKey(for mood: MoodType) -> String {
        return "cache_timestamp_\(mood.rawValue)"
    }
    
    private func likesKey(for mood: MoodType) -> String {
        return "liked_tracks_\(mood.rawValue)"
    }
    
    // MARK: - Cache Management
    func cacheTracks(_ tracks: [Track], for mood: MoodType) {
        do {
            let data = try JSONEncoder().encode(tracks)
            userDefaults.set(data, forKey: tracksKey(for: mood))
            userDefaults.set(Date().timeIntervalSince1970, forKey: timestampKey(for: mood))
        } catch {
            print("Failed to cache tracks for \(mood.rawValue): \(error)")
        }
    }
    
    func getCachedTracks(for mood: MoodType) -> [Track]? {
        guard isCacheValid(for: mood) else { return nil }
        
        guard let data = userDefaults.data(forKey: tracksKey(for: mood)) else {
            return nil
        }
        
        do {
            var tracks = try JSONDecoder().decode([Track].self, from: data)
            // Apply current like states
            let likedTrackIDs = getLikedTrackIDs(for: mood)
            tracks = tracks.map { track in
                var updatedTrack = track
                updatedTrack.isLiked = likedTrackIDs.contains(track.id)
                return updatedTrack
            }
            return tracks
        } catch {
            print("Failed to decode cached tracks for \(mood.rawValue): \(error)")
            return nil
        }
    }
    
    func isCacheValid(for mood: MoodType) -> Bool {
        let timestamp = userDefaults.double(forKey: timestampKey(for: mood))
        let currentTime = Date().timeIntervalSince1970
        return (currentTime - timestamp) < cacheExpirationTime
    }
    
    func clearCache(for mood: MoodType) {
        userDefaults.removeObject(forKey: tracksKey(for: mood))
        userDefaults.removeObject(forKey: timestampKey(for: mood))
    }
    
    // MARK: - Like Management
    func toggleLike(trackID: String, for mood: MoodType) {
        var likedTracks = getLikedTrackIDs(for: mood)
        
        if likedTracks.contains(trackID) {
            likedTracks.remove(trackID)
        } else {
            likedTracks.insert(trackID)
        }
        
        let array = Array(likedTracks)
        userDefaults.set(array, forKey: likesKey(for: mood))
    }
    
    func isLiked(trackID: String, for mood: MoodType) -> Bool {
        return getLikedTrackIDs(for: mood).contains(trackID)
    }
    
    private func getLikedTrackIDs(for mood: MoodType) -> Set<String> {
        let array = userDefaults.stringArray(forKey: likesKey(for: mood)) ?? []
        return Set(array)
    }
    
    func getLikedTracks(for mood: MoodType) -> [Track] {
        guard let cachedTracks = getCachedTracks(for: mood) else { return [] }
        let likedTrackIDs = getLikedTrackIDs(for: mood)
        return cachedTracks.filter { likedTrackIDs.contains($0.id) }
    }
}