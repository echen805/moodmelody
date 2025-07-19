import Foundation

struct UserFeedback: Codable, Identifiable {
    let id: String
    let originalInput: String
    let detectedMood: MoodType
    let correctedMood: MoodType?
    let userAction: FeedbackAction
    let timestamp: Date
    let sessionId: String
    
    enum FeedbackAction: String, Codable, CaseIterable {
        case moodCorrected = "mood_corrected"
        case searchAgain = "search_again"
        case resultsNotGood = "results_not_good"
        case moodAccepted = "mood_accepted"
    }
    
    init(
        originalInput: String,
        detectedMood: MoodType,
        correctedMood: MoodType? = nil,
        userAction: FeedbackAction,
        sessionId: String = UUID().uuidString
    ) {
        self.id = UUID().uuidString
        self.originalInput = originalInput
        self.detectedMood = detectedMood
        self.correctedMood = correctedMood
        self.userAction = userAction
        self.timestamp = Date()
        self.sessionId = sessionId
    }
}

// Make MoodType Codable
extension MoodType: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case customValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "happy": self = .happy
        case "sad": self = .sad
        case "angry": self = .angry
        case "frustrated": self = .frustrated
        case "energetic": self = .energetic
        case "calm": self = .calm
        case "nostalgic": self = .nostalgic
        case "romantic": self = .romantic
        case "melancholic": self = .melancholic
        case "excited": self = .excited
        case "custom":
            let customValue = try container.decode(String.self, forKey: .customValue)
            self = .custom(customValue)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown mood type")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .happy:
            try container.encode("happy", forKey: .type)
        case .sad:
            try container.encode("sad", forKey: .type)
        case .angry:
            try container.encode("angry", forKey: .type)
        case .frustrated:
            try container.encode("frustrated", forKey: .type)
        case .energetic:
            try container.encode("energetic", forKey: .type)
        case .calm:
            try container.encode("calm", forKey: .type)
        case .nostalgic:
            try container.encode("nostalgic", forKey: .type)
        case .romantic:
            try container.encode("romantic", forKey: .type)
        case .melancholic:
            try container.encode("melancholic", forKey: .type)
        case .excited:
            try container.encode("excited", forKey: .type)
        case .custom(let value):
            try container.encode("custom", forKey: .type)
            try container.encode(value, forKey: .customValue)
        }
    }
}