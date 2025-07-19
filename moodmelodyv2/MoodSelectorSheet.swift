import SwiftUI

struct MoodSelectorSheet: View {
    @Binding var isPresented: Bool
    let onMoodSelected: (MoodType) -> Void
    let currentMood: MoodType
    
    private let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Select the correct mood")
                        .font(.headline)
                    
                    Text("Help us learn by choosing the mood that better matches your feeling")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(MoodType.allCases, id: \.id) { mood in
                            MoodOptionCard(
                                mood: mood,
                                isSelected: mood == currentMood,
                                onTap: {
                                    onMoodSelected(mood)
                                    isPresented = false
                                }
                            )
                        }
                        
                        // Custom mood option
                        CustomMoodCard { customMood in
                            onMoodSelected(customMood)
                            isPresented = false
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Correct Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct MoodOptionCard: View {
    let mood: MoodType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                Text(mood.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color.opacity(0.3) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct CustomMoodCard: View {
    let onCustomMood: (MoodType) -> Void
    @State private var showingCustomInput = false
    @State private var customText = ""
    
    var body: some View {
        Button {
            showingCustomInput = true
        } label: {
            VStack(spacing: 8) {
                Text("🎵")
                    .font(.system(size: 32))
                
                Text("Custom")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCustomInput) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Enter your mood")
                        .font(.headline)
                    
                    TextField("Describe your mood...", text: $customText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                    
                    Button("Done") {
                        if !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onCustomMood(.custom(customText))
                            showingCustomInput = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Custom Mood")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showingCustomInput = false
                        }
                    }
                }
            }
        }
    }
}