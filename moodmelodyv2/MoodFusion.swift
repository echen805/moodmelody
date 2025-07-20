import Foundation
import SwiftUI

struct MoodFusion {
    let primaryMood: MoodType
    let secondaryMood: MoodType?
    let intensity: MoodIntensity
    
    enum MoodIntensity: String, CaseIterable {
        case subtle = "subtle"
        case moderate = "moderate"
        case strong = "strong"
        
        var modifier: String {
            switch self {
            case .subtle: return "gentle"
            case .moderate: return ""
            case .strong: return "intense"
            }
        }
    }
    
    init(primary: MoodType, secondary: MoodType? = nil, intensity: MoodIntensity = .moderate) {
        self.primaryMood = primary
        self.secondaryMood = secondary
        self.intensity = intensity
    }
    
    var searchTerm: String {
        guard let secondary = secondaryMood else {
            return "\(intensity.modifier) \(primaryMood.searchTerm())".trimmingCharacters(in: .whitespaces)
        }
        
        // Create fusion search terms
        let fusionTerms = createFusionSearchTerm(primary: primaryMood, secondary: secondary, intensity: intensity)
        return fusionTerms
    }
    
    var displayName: String {
        guard let secondary = secondaryMood else {
            return primaryMood.rawValue
        }
        
        return "\(primaryMood.rawValue) + \(secondary.rawValue)"
    }
    
    var emoji: String {
        guard let secondary = secondaryMood else {
            return primaryMood.emoji
        }
        
        return "\(primaryMood.emoji)\(secondary.emoji)"
    }
    
    var color: Color {
        guard let secondary = secondaryMood else {
            return primaryMood.color
        }
        
        // Blend colors for fusion moods
        return blendColors(primaryMood.color, secondary.color)
    }
    
    private func createFusionSearchTerm(primary: MoodType, secondary: MoodType, intensity: MoodIntensity) -> String {
        // Define fusion combinations
        let fusionCombinations: [String: String] = [
            "calm+energetic": "chill but energetic music",
            "energetic+calm": "energetic but relaxed music",
            "happy+sad": "bittersweet uplifting music",
            "sad+happy": "melancholic but hopeful music",
            "romantic+nostalgic": "romantic nostalgic love songs",
            "nostalgic+romantic": "nostalgic romantic music",
            "excited+calm": "excited but peaceful music",
            "calm+excited": "peaceful but uplifting music",
            "angry+calm": "intense but controlled music",
            "calm+angry": "relaxed but powerful music",
            "energetic+melancholic": "energetic but introspective music",
            "melancholic+energetic": "moody but dynamic music",
            "frustrated+calm": "frustrated but soothing music",
            "calm+frustrated": "peaceful but intense music"
        ]
        
        let key = "\(primary.rawValue.lowercased())+\(secondary.rawValue.lowercased())"
        let reverseKey = "\(secondary.rawValue.lowercased())+\(primary.rawValue.lowercased())"
        
        if let fusionTerm = fusionCombinations[key] ?? fusionCombinations[reverseKey] {
            return "\(intensity.modifier) \(fusionTerm)".trimmingCharacters(in: .whitespaces)
        }
        
        // Default fusion
        return "\(intensity.modifier) \(primary.searchTerm()) with \(secondary.searchTerm())".trimmingCharacters(in: .whitespaces)
    }
    
    private func blendColors(_ color1: Color, _ color2: Color) -> Color {
        // Simple color blending - in a real app you'd want more sophisticated blending
        // For now, just return the primary color with some opacity
        return color1.opacity(0.8)
    }
}

extension MoodFusion {
    static func inferFusion(from text: String) -> MoodFusion? {
        let lowercasedText = text.lowercased()
        
        // Check for fusion indicators
        let fusionIndicators = ["but", "and", "with", "while", "yet", "however", "though", "although"]
        var hasFusion = false
        var fusionWord = ""
        
        for indicator in fusionIndicators {
            if lowercasedText.contains(indicator) {
                hasFusion = true
                fusionWord = indicator
                break
            }
        }
        
        if !hasFusion {
            return nil
        }
        
        // Split text by fusion indicator
        let parts = lowercasedText.components(separatedBy: fusionWord)
        guard parts.count >= 2 else { return nil }
        
        let firstPart = parts[0].trimmingCharacters(in: .whitespaces)
        let secondPart = parts[1].trimmingCharacters(in: .whitespaces)
        
        let (firstMood, _) = MoodType.inferMood(from: firstPart)
        let (secondMood, _) = MoodType.inferMood(from: secondPart)
        
        // Don't create fusion if both moods are the same or if one is custom
        if firstMood == secondMood {
            return nil
        }
        
        if case .custom(_) = firstMood {
            return nil
        }
        
        if case .custom(_) = secondMood {
            return nil
        }
        
        // Determine intensity
        let intensity: MoodFusion.MoodIntensity
        if lowercasedText.contains("very") || lowercasedText.contains("really") || lowercasedText.contains("extremely") {
            intensity = .strong
        } else if lowercasedText.contains("slightly") || lowercasedText.contains("kind of") || lowercasedText.contains("a bit") {
            intensity = .subtle
        } else {
            intensity = .moderate
        }
        
        return MoodFusion(primary: firstMood, secondary: secondMood, intensity: intensity)
    }
} 