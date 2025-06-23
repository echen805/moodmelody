import Foundation

public struct Track: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let artist: String
    public let artworkURL: URL?
    public let previewURL: URL?
    public let catalogID: String?
    public var isLiked: Bool
    public let dateAdded: Date
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        artworkURL: URL? = nil,
        previewURL: URL? = nil,
        catalogID: String? = nil,
        isLiked: Bool = false,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.previewURL = previewURL
        self.catalogID = catalogID
        self.isLiked = isLiked
        self.dateAdded = dateAdded
    }
    
    public func toggleLike() -> Track {
        return Track(
            id: id,
            title: title,
            artist: artist,
            artworkURL: artworkURL,
            previewURL: previewURL,
            catalogID: catalogID,
            isLiked: !isLiked,
            dateAdded: dateAdded
        )
    }
}

// MARK: - Sample Data
extension Track {
    public static let sampleTracks: [Track] = [
        Track(
            title: "Happy Song",
            artist: "Artist One",
            artworkURL: URL(string: "https://example.com/artwork1.jpg"),
            previewURL: URL(string: "https://example.com/preview1.mp3")
        ),
        Track(
            title: "Sad Melody",
            artist: "Artist Two",
            artworkURL: URL(string: "https://example.com/artwork2.jpg"),
            previewURL: URL(string: "https://example.com/preview2.mp3")
        )
    ]
}