import Foundation
import SwiftUI

enum MoodType: Identifiable, Equatable, Hashable {
    case happy
    case sad
    case angry
    case frustrated
    case energetic
    case calm
    case nostalgic
    case romantic
    case melancholic
    case excited
    case custom(String)

    var id: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .frustrated: return "Frustrated"
        case .energetic: return "Energetic"
        case .calm: return "Calm"
        case .nostalgic: return "Nostalgic"
        case .romantic: return "Romantic"
        case .melancholic: return "Melancholic"
        case .excited: return "Excited"
        case .custom(let term): return "Custom: \(term)"
        }
    }

    var rawValue: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .frustrated: return "Frustrated"
        case .energetic: return "Energetic"
        case .calm: return "Calm"
        case .nostalgic: return "Nostalgic"
        case .romantic: return "Romantic"
        case .melancholic: return "Melancholic"
        case .excited: return "Excited"
        case .custom(let term): return term.capitalized
        }
    }
    
    static var allCases: [MoodType] {
        return [.happy, .sad, .angry, .frustrated, .energetic, .calm, .nostalgic, .romantic, .melancholic, .excited]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var searchTerm: String {
        switch self {
        case .happy:
            return "happy upbeat mood music"
        case .sad:
            return "sad melancholy mood music"
        case .angry:
            return "angry intense mood music"
        case .frustrated:
            return "frustrated alternative mood music"
        case .energetic:
            return "energetic high energy workout music"
        case .calm:
            return "calm relaxing peaceful music"
        case .nostalgic:
            return "nostalgic throwback retro music"
        case .romantic:
            return "romantic love songs music"
        case .melancholic:
            return "melancholic moody introspective music"
        case .excited:
            return "excited uplifting celebratory music"
        case .custom(let term):
            return term
        }
    }
    
    var emoji: String {
        switch self {
        case .happy:
            return "😊"
        case .sad:
            return "😢"
        case .angry:
            return "😡"
        case .frustrated:
            return "😤"
        case .energetic:
            return "⚡"
        case .calm:
            return "😌"
        case .nostalgic:
            return "🌅"
        case .romantic:
            return "💕"
        case .melancholic:
            return "🌧️"
        case .excited:
            return "🎉"
        case .custom:
            return "🎵"
        }
    }
    
    var color: Color {
        switch self {
        case .happy:
            return .yellow
        case .sad:
            return .blue
        case .angry:
            return .red
        case .frustrated:
            return .orange
        case .energetic:
            return .green
        case .calm:
            return .mint
        case .nostalgic:
            return .purple
        case .romantic:
            return .pink
        case .melancholic:
            return .indigo
        case .excited:
            return .cyan
        case .custom:
            return .gray
        }
    }
    
    var keywords: [String] {
        switch self {
        case .happy:
            return ["happy", "joyful", "cheerful", "glad", "content", "upbeat", "positive", "good", "great", "amazing", "wonderful", "fantastic", "excited", "thrilled", "delighted"]
        case .sad:
            return ["sad", "depressed", "down", "blue", "gloomy", "miserable", "unhappy", "sorrowful", "melancholy", "dejected", "heartbroken", "disappointed", "hurt", "crying", "tears"]
        case .angry:
            return ["angry", "mad", "furious", "rage", "pissed", "livid", "enraged", "irate", "annoyed", "irritated", "hostile", "aggressive", "violent", "hateful"]
        case .frustrated:
            return ["frustrated", "annoyed", "irritated", "bothered", "stressed", "overwhelmed", "exhausted", "tired", "fed up", "sick of", "done with", "agitated"]
        case .energetic:
            return ["energetic", "hyper", "pumped", "motivated", "active", "dynamic", "vigorous", "lively", "spirited", "workout", "exercise", "run", "gym"]
        case .calm:
            return ["calm", "relaxed", "peaceful", "serene", "tranquil", "quiet", "still", "zen", "meditative", "chill", "laid back", "mellow", "soothing"]
        case .nostalgic:
            return ["nostalgic", "reminiscent", "throwback", "memories", "past", "old times", "vintage", "retro", "remember", "childhood", "youth", "missing"]
        case .romantic:
            return ["romantic", "love", "loving", "affectionate", "intimate", "tender", "sweet", "passionate", "crush", "relationship", "dating", "valentine"]
        case .melancholic:
            return ["melancholic", "moody", "somber", "pensive", "reflective", "introspective", "contemplative", "wistful", "bittersweet", "longing", "yearning"]
        case .excited:
            return ["excited", "thrilled", "psyched", "pumped up", "enthusiastic", "eager", "anticipating", "looking forward", "can't wait", "celebration", "party"]
        case .custom:
            return [] // Custom moods don't have predefined keywords
        }
    }
    
    static func inferMood(from text: String) -> MoodType {
        let lowercasedText = text.lowercased()
        
        // Check for musical terminology first
        let musicTerms = ["instrumental", "acoustic", "live", "remix", "cover", "classical", "jazz", "electronic", "hip hop", "rock", "pop"]
        for term in musicTerms {
            if lowercasedText.contains(term) {
                // You can get more specific with the search term here
                return .custom("\(term) music")
            }
        }
        
        // If no music term, infer emotional mood
        let words = lowercasedText.components(separatedBy: .whitespacesAndNewlines)
        var moodScores: [MoodType: Int] = [:]
        
        for mood in MoodType.allCases {
            moodScores[mood] = 0
        }
        
        for word in words {
            for mood in MoodType.allCases {
                for keyword in mood.keywords {
                    if word.contains(keyword) || keyword.contains(word) {
                        moodScores[mood, default: 0] += 1
                    }
                }
            }
        }
        
        let bestMood = moodScores.max { $0.value < $1.value }
        
        // If a mood was found, return it, otherwise default to a custom search
        if let mood = bestMood?.key, moodScores[mood]! > 0 {
            return mood
        } else {
            // If no keywords matched, use the original text as a custom search
            return .custom(text)
        }
    }
}