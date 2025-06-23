import Foundation

public enum MoodType: String, CaseIterable, Identifiable {
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case frustrated = "Frustrated"
    
    public var id: String { rawValue }
    
    public var searchTerm: String {
        switch self {
        case .happy:
            return "happy upbeat mood music"
        case .sad:
            return "sad melancholy mood music"
        case .angry:
            return "angry intense mood music"
        case .frustrated:
            return "frustrated alternative mood music"
        }
    }
    
    public var emoji: String {
        switch self {
        case .happy:
            return "😊"
        case .sad:
            return "😢"
        case .angry:
            return "😡"
        case .frustrated:
            return "😤"
        }
    }
    
    public var color: String {
        switch self {
        case .happy:
            return "yellow"
        case .sad:
            return "blue"
        case .angry:
            return "red"
        case .frustrated:
            return "orange"
        }
    }
}