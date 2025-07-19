import Foundation

@MainActor
class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()
    
    private let userDefaults = UserDefaults.standard
    private let feedbackKey = "user_feedback_data"
    
    @Published var feedbackCount: Int = 0
    
    private init() {
        updateFeedbackCount()
    }
    
    // MARK: - Feedback Management
    
    func recordFeedback(_ feedback: UserFeedback) {
        var existingFeedback = getAllFeedback()
        existingFeedback.append(feedback)
        
        // Keep only last 1000 feedback entries to prevent storage bloat
        if existingFeedback.count > 1000 {
            existingFeedback = Array(existingFeedback.suffix(1000))
        }
        
        saveFeedback(existingFeedback)
        updateFeedbackCount()
        
        print("Recorded feedback: \(feedback.userAction.rawValue) for input: '\(feedback.originalInput)'")
    }
    
    func recordMoodCorrection(
        originalInput: String,
        detectedMood: MoodType,
        correctedMood: MoodType,
        sessionId: String
    ) {
        let feedback = UserFeedback(
            originalInput: originalInput,
            detectedMood: detectedMood,
            correctedMood: correctedMood,
            userAction: .moodCorrected,
            sessionId: sessionId
        )
        recordFeedback(feedback)
    }
    
    func recordSearchAgain(
        originalInput: String,
        detectedMood: MoodType,
        sessionId: String
    ) {
        let feedback = UserFeedback(
            originalInput: originalInput,
            detectedMood: detectedMood,
            userAction: .searchAgain,
            sessionId: sessionId
        )
        recordFeedback(feedback)
    }
    
    func recordResultsNotGood(
        originalInput: String,
        detectedMood: MoodType,
        sessionId: String
    ) {
        let feedback = UserFeedback(
            originalInput: originalInput,
            detectedMood: detectedMood,
            userAction: .resultsNotGood,
            sessionId: sessionId
        )
        recordFeedback(feedback)
    }
    
    func recordMoodAccepted(
        originalInput: String,
        detectedMood: MoodType,
        sessionId: String
    ) {
        let feedback = UserFeedback(
            originalInput: originalInput,
            detectedMood: detectedMood,
            userAction: .moodAccepted,
            sessionId: sessionId
        )
        recordFeedback(feedback)
    }
    
    // MARK: - Data Retrieval
    
    func getAllFeedback() -> [UserFeedback] {
        guard let data = userDefaults.data(forKey: feedbackKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([UserFeedback].self, from: data)
        } catch {
            print("Failed to decode feedback data: \(error)")
            return []
        }
    }
    
    func getFeedbackForExport() -> String {
        let feedback = getAllFeedback()
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(feedback)
            return String(data: data, encoding: .utf8) ?? "Failed to encode feedback"
        } catch {
            return "Failed to export feedback: \(error.localizedDescription)"
        }
    }
    
    func getMoodCorrectionStats() -> [String: Int] {
        let feedback = getAllFeedback()
        let corrections = feedback.filter { $0.userAction == .moodCorrected }
        
        var stats: [String: Int] = [:]
        
        for correction in corrections {
            let key = "\(correction.detectedMood.rawValue) → \(correction.correctedMood?.rawValue ?? "Unknown")"
            stats[key, default: 0] += 1
        }
        
        return stats
    }
    
    // MARK: - Data Management
    
    func clearAllFeedback() {
        userDefaults.removeObject(forKey: feedbackKey)
        updateFeedbackCount()
        print("Cleared all feedback data")
    }
    
    private func saveFeedback(_ feedback: [UserFeedback]) {
        do {
            let data = try JSONEncoder().encode(feedback)
            userDefaults.set(data, forKey: feedbackKey)
        } catch {
            print("Failed to save feedback: \(error)")
        }
    }
    
    private func updateFeedbackCount() {
        feedbackCount = getAllFeedback().count
    }
    
    // MARK: - Analytics Helpers
    
    func getInsights() -> FeedbackInsights {
        let allFeedback = getAllFeedback()
        
        let totalSessions = Set(allFeedback.map { $0.sessionId }).count
        let correctionsCount = allFeedback.filter { $0.userAction == .moodCorrected }.count
        let searchAgainCount = allFeedback.filter { $0.userAction == .searchAgain }.count
        let notGoodCount = allFeedback.filter { $0.userAction == .resultsNotGood }.count
        let acceptedCount = allFeedback.filter { $0.userAction == .moodAccepted }.count
        
        let accuracyRate = totalSessions > 0 ? (Double(acceptedCount) / Double(totalSessions)) * 100 : 0
        
        return FeedbackInsights(
            totalSessions: totalSessions,
            correctionsCount: correctionsCount,
            searchAgainCount: searchAgainCount,
            notGoodCount: notGoodCount,
            acceptedCount: acceptedCount,
            accuracyRate: accuracyRate
        )
    }
}

struct FeedbackInsights {
    let totalSessions: Int
    let correctionsCount: Int
    let searchAgainCount: Int
    let notGoodCount: Int
    let acceptedCount: Int
    let accuracyRate: Double
}