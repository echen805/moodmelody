import SwiftUI

struct MoodInputView: View {
    @State private var feelingText: String = ""
    @State private var inferredMood: MoodType?
    @State private var showingTrackList = false
    @State private var isAnalyzing = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                        
                        Button("Find My Music") {
                            showingTrackList = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
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
            }
            .navigationTitle("MoodMelody")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                isTextFieldFocused = false
            }
            .sheet(isPresented: $showingTrackList) {
                if let mood = inferredMood {
                    TrackListView(mood: mood)
                }
            }
        }
    }
    
    private func analyzeMood() {
        guard !feelingText.isEmpty else { return }
        
        isAnalyzing = true
        isTextFieldFocused = false
        
        // Simulate analysis delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                inferredMood = MoodType.inferMood(from: feelingText)
                isAnalyzing = false
            }
        }
    }
}

#Preview {
    MoodInputView()
}