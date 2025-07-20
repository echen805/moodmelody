import Foundation
import SwiftUI

enum MoodIntensity: String, CaseIterable {
    case chill = "chill"
    case smooth = "smooth"
    case intense = "intense"
    case energetic = "energetic"
    case mellow = "mellow"
    case powerful = "powerful"
    case gentle = "gentle"
    case dynamic = "dynamic"
    case laidBack = "laid back"
    case vibrant = "vibrant"
    
    var modifier: String {
        return self.rawValue
    }
}

enum MoodType: Hashable, Identifiable {
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
    
    func searchTerm(with intensity: MoodIntensity? = nil) -> String {
        let baseTerm = baseSearchTerm
        if let intensity = intensity {
            return "\(intensity.modifier) \(baseTerm)"
        }
        return baseTerm
    }
    
    private var baseSearchTerm: String {
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
    
    // Enhanced search terms for different intensities
    func enhancedSearchTerm(with intensity: MoodIntensity? = nil) -> String {
        switch self {
        case .happy:
            switch intensity {
            case .chill: return "chill happy lofi beats"
            case .smooth: return "smooth happy jazz"
            case .intense: return "intense happy electronic dance"
            case .energetic: return "energetic happy pop rock"
            case .mellow: return "mellow happy acoustic"
            case .powerful: return "powerful happy anthems"
            case .gentle: return "gentle happy folk"
            case .dynamic: return "dynamic happy funk"
            case .laidBack: return "laid back happy reggae"
            case .vibrant: return "vibrant happy world music"
            case .none: return "happy upbeat mood music"
            }
        case .sad:
            switch intensity {
            case .chill: return "chill sad ambient"
            case .smooth: return "smooth sad blues"
            case .intense: return "intense sad rock ballads"
            case .energetic: return "energetic sad alternative"
            case .mellow: return "mellow sad acoustic"
            case .powerful: return "powerful sad orchestral"
            case .gentle: return "gentle sad piano"
            case .dynamic: return "dynamic sad indie"
            case .laidBack: return "laid back sad folk"
            case .vibrant: return "vibrant sad electronic"
            case .none: return "sad melancholy mood music"
            }
        case .angry:
            switch intensity {
            case .chill: return "chill angry dark ambient"
            case .smooth: return "smooth angry blues rock"
            case .intense: return "intense angry metal"
            case .energetic: return "energetic angry punk"
            case .mellow: return "mellow angry grunge"
            case .powerful: return "powerful angry industrial"
            case .gentle: return "gentle angry acoustic"
            case .dynamic: return "dynamic angry rap"
            case .laidBack: return "laid back angry stoner rock"
            case .vibrant: return "vibrant angry electronic"
            case .none: return "angry intense mood music"
            }
        case .frustrated:
            switch intensity {
            case .chill: return "chill frustrated ambient"
            case .smooth: return "smooth frustrated jazz"
            case .intense: return "intense frustrated rock"
            case .energetic: return "energetic frustrated electronic"
            case .mellow: return "mellow frustrated acoustic"
            case .powerful: return "powerful frustrated metal"
            case .gentle: return "gentle frustrated piano"
            case .dynamic: return "dynamic frustrated hip hop"
            case .laidBack: return "laid back frustrated folk"
            case .vibrant: return "vibrant frustrated world"
            case .none: return "frustrated alternative mood music"
            }
        case .energetic:
            switch intensity {
            case .chill: return "chill energetic lofi"
            case .smooth: return "smooth energetic jazz fusion"
            case .intense: return "intense energetic electronic"
            case .energetic: return "energetic high energy workout"
            case .mellow: return "mellow energetic acoustic"
            case .powerful: return "powerful energetic rock"
            case .gentle: return "gentle energetic folk"
            case .dynamic: return "dynamic energetic funk"
            case .laidBack: return "laid back energetic reggae"
            case .vibrant: return "vibrant energetic world"
            case .none: return "energetic high energy workout music"
            }
        case .calm:
            switch intensity {
            case .chill: return "chill calm lofi"
            case .smooth: return "smooth calm jazz"
            case .intense: return "intense calm ambient"
            case .energetic: return "energetic calm acoustic"
            case .mellow: return "mellow calm piano"
            case .powerful: return "powerful calm orchestral"
            case .gentle: return "gentle calm meditation"
            case .dynamic: return "dynamic calm world"
            case .laidBack: return "laid back calm folk"
            case .vibrant: return "vibrant calm nature sounds"
            case .none: return "calm relaxing peaceful music"
            }
        case .nostalgic:
            switch intensity {
            case .chill: return "chill nostalgic lofi"
            case .smooth: return "smooth nostalgic jazz"
            case .intense: return "intense nostalgic rock"
            case .energetic: return "energetic nostalgic pop"
            case .mellow: return "mellow nostalgic acoustic"
            case .powerful: return "powerful nostalgic orchestral"
            case .gentle: return "gentle nostalgic piano"
            case .dynamic: return "dynamic nostalgic funk"
            case .laidBack: return "laid back nostalgic folk"
            case .vibrant: return "vibrant nostalgic world"
            case .none: return "nostalgic throwback retro music"
            }
        case .romantic:
            switch intensity {
            case .chill: return "chill romantic lofi"
            case .smooth: return "smooth romantic jazz"
            case .intense: return "intense romantic ballads"
            case .energetic: return "energetic romantic pop"
            case .mellow: return "mellow romantic acoustic"
            case .powerful: return "powerful romantic orchestral"
            case .gentle: return "gentle romantic piano"
            case .dynamic: return "dynamic romantic r&b"
            case .laidBack: return "laid back romantic folk"
            case .vibrant: return "vibrant romantic world"
            case .none: return "romantic love songs music"
            }
        case .melancholic:
            switch intensity {
            case .chill: return "chill melancholic ambient"
            case .smooth: return "smooth melancholic blues"
            case .intense: return "intense melancholic rock"
            case .energetic: return "energetic melancholic electronic"
            case .mellow: return "mellow melancholic acoustic"
            case .powerful: return "powerful melancholic orchestral"
            case .gentle: return "gentle melancholic piano"
            case .dynamic: return "dynamic melancholic indie"
            case .laidBack: return "laid back melancholic folk"
            case .vibrant: return "vibrant melancholic world"
            case .none: return "melancholic moody introspective music"
            }
        case .excited:
            switch intensity {
            case .chill: return "chill excited lofi"
            case .smooth: return "smooth excited jazz"
            case .intense: return "intense excited electronic"
            case .energetic: return "energetic excited pop"
            case .mellow: return "mellow excited acoustic"
            case .powerful: return "powerful excited rock"
            case .gentle: return "gentle excited folk"
            case .dynamic: return "dynamic excited funk"
            case .laidBack: return "laid back excited reggae"
            case .vibrant: return "vibrant excited world"
            case .none: return "excited uplifting celebratory music"
            }
        case .custom(let term):
            if let intensity = intensity {
                return "\(intensity.modifier) \(term)"
            }
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
    
    // Intensity keywords for better mood detection
    var intensityKeywords: [String] {
        return ["chill", "smooth", "intense", "energetic", "mellow", "powerful", "gentle", "dynamic", "laid back", "vibrant", "soft", "hard", "quiet", "loud", "fast", "slow"]
    }
    
    static func inferMood(from text: String) -> (MoodType, MoodIntensity?) {
        let lowercasedText = text.lowercased()
        
        // Check for intensity modifiers first
        var detectedIntensity: MoodIntensity?
        for intensity in MoodIntensity.allCases {
            if lowercasedText.contains(intensity.rawValue) {
                detectedIntensity = intensity
                break
            }
        }
        
        // Check for musical terminology first
        let musicTerms = ["instrumental", "acoustic", "live", "remix", "cover", "classical", "jazz", "electronic", "hip hop", "rock", "pop", "lofi", "ambient", "blues", "folk", "funk", "reggae", "world"]
        for term in musicTerms {
            if lowercasedText.contains(term) {
                return (.custom("\(term) music"), detectedIntensity)
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
            return (mood, detectedIntensity)
        } else {
            // If no keywords matched, use the original text as a custom search
            return (.custom(text), detectedIntensity)
        }
    }
}