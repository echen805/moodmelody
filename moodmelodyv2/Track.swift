import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    let catalogID: String?
    var isLiked: Bool
    let dateAdded: Date
    
    init(
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
    
    func toggleLike() -> Track {
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