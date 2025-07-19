import SwiftUI

struct MoodInputView: View {
    @State private var feelingText: String = ""
    @State private var inferredMood: MoodType?
    @State private var showingTrackList = false
    @State private var isAnalyzing = false
    @State private var showingMoodSelector = false
    @State private var sessionId = UUID().uuidString
    @FocusState private var isTextFieldFocused: Bool
    
    @StateObject private var feedbackManager = FeedbackManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("How are you feeling?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Tell us about your mood and we'll find the perfect music")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 50)
                
                // Text Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Describe your feelings")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("I'm feeling...", text: $feelingText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            analyzeMood()
                        }
                    
                    Text("e.g., \"Happy instrumentals\" or \"Feeling sad and lonely\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Mood Preview
                if let mood = inferredMood {
                    VStack(spacing: 12) {
                        Text("We detect you're feeling:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(mood.emoji)
                                .font(.largeTitle)
                            
                            VStack(alignment: .leading) {
                                Text(mood.rawValue)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Perfect for \(mood.searchTerm)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(mood.color.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button("Find My Music") {
                                // Record that user accepted the mood
                                feedbackManager.recordMoodAccepted(
                                    originalInput: feelingText,
                                    detectedMood: mood,
                                    sessionId: sessionId
                                )
                                showingTrackList = true
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.regular)
                            
                            Button("Not quite right?") {
                                showingMoodSelector = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.regular)
                        }
                        
                        Button("Search Again") {
                            searchAgain()
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .transition(.slide)
                }
                
                // Analyze Button
                if inferredMood == nil && !feelingText.isEmpty {
                    Button {
                        analyzeMood()
                    } label: {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.white)
                            }
                            Text(isAnalyzing ? "Analyzing..." : "Analyze My Mood")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isAnalyzing)
                }
                
                Spacer()
                
                // Feedback count (for debugging/info)
                if feedbackManager.feedbackCount > 0 {
                    Text("\(feedbackManager.feedbackCount) feedback entries stored")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("MoodMelody")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                isTextFieldFocused = false
            }
            .sheet(isPresented: $showingTrackList) {
                if let mood = inferredMood {
                    TrackListView(
                        mood: mood,
                        originalInput: feelingText,
                        sessionId: sessionId
                    )
                }
            }
            .sheet(isPresented: $showingMoodSelector) {
                if let currentMood = inferredMood {
                    MoodSelectorSheet(
                        isPresented: $showingMoodSelector,
                        onMoodSelected: { correctedMood in
                            // Record the mood correction
                            feedbackManager.recordMoodCorrection(
                                originalInput: feelingText,
                                detectedMood: currentMood,
                                correctedMood: correctedMood,
                                sessionId: sessionId
                            )
                            
                            // Update the mood and show tracks
                            withAnimation {
                                inferredMood = correctedMood
                            }
                            
                            // Automatically show track list after correction
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showingTrackList = true
                            }
                        },
                        currentMood: currentMood
                    )
                }
            }
        }
    }
    
    private func analyzeMood() {
        guard !feelingText.isEmpty else { return }
        
        isAnalyzing = true
        isTextFieldFocused = false
        
        // Generate new session ID for this analysis
        sessionId = UUID().uuidString
        
        // Simulate analysis delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                inferredMood = MoodType.inferMood(from: feelingText)
                isAnalyzing = false
            }
        }
    }
    
    private func searchAgain() {
        guard let mood = inferredMood else { return }
        
        // Record search again feedback
        feedbackManager.recordSearchAgain(
            originalInput: feelingText,
            detectedMood: mood,
            sessionId: sessionId
        )
        
        // Reset state and start over
        withAnimation {
            inferredMood = nil
            feelingText = ""
            sessionId = UUID().uuidString
        }
        
        // Focus back on text field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    MoodInputView()
}