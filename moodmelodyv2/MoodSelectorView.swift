import SwiftUI

struct MoodSelectorView: View {
    @State private var selectedMood: MoodType?
    @State private var showTrackList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose your mood to get personalized music recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Mood Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(MoodType.allCases) { mood in
                        MoodButton(mood: mood) {
                            selectedMood = mood
                            showTrackList = true
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("MoodMelody")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTrackList) {
                if let mood = selectedMood {
                    TrackListView(mood: mood)
                }
            }
        }
    }
}
