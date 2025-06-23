import SwiftUI

struct MoodButton: View {
    let mood: MoodType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 40))
                
                Text(mood.rawValue)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorForMood(mood))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func colorForMood(_ mood: MoodType) -> Color {
        switch mood {
        case .happy:
            return .yellow
        case .sad:
            return .blue
        case .angry:
            return .red
        case .frustrated:
            return .orange
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}