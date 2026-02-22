import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                // Top label
                Text("SignBridge")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                // Camera placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .overlay(
                        Text("Camera will go here")
                            .foregroundStyle(.white.opacity(0.5))
                    )

                // Gesture token placeholder
                Text("GESTURE TOKEN")
                    .font(.title2.bold())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)

                // Phrase suggestion placeholder
                Text("Suggested phrase will appear here")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.body)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
