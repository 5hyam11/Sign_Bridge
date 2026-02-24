import SwiftUI

struct ContentView: View {
    @StateObject private var cameraSession = CameraSession()

    var body: some View {
        ZStack {
            // Live camera feed
            CameraPreviewView(session: cameraSession)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top label
                Text("SignBridge")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 60)

                Spacer()

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
                    .padding(.bottom, 60)
            }
        }
        .onAppear { cameraSession.start() }
        .onDisappear { cameraSession.stop() }
    }
}

#Preview {
    ContentView()
}
