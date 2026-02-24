import SwiftUI

struct ContentView: View {
    @StateObject private var cameraSession    = CameraSession()
    @StateObject private var smoother         = GestureSmoother()
    @StateObject private var phrasePredictor  = PhrasePredictor()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var speechSynth      = SpeechSynthesizer()

    @State private var isListeningMode = false
    @State private var lastCommittedToken: GestureToken? = nil

    var body: some View {
        ZStack {
            // Live camera feed
            CameraPreviewView(session: cameraSession)
                .ignoresSafeArea()

            // Dark overlay for readability
            Color.black.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 0) {

                // ── TOP: App title ──
                Text("SignBridge")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 12)

                // ── STT transcript (hearing person speaking) ──
                if isListeningMode && !speechRecognizer.transcript.isEmpty {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                // ── Token trail ──
                if !phrasePredictor.tokenBuffer.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(phrasePredictor.tokenBuffer, id: \.self) { token in
                                Text("\(token.emoji) \(token.rawValue)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(token.color.opacity(0.3))
                                    .clipShape(Capsule())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                // ── Current gesture token badge ──
                if let token = smoother.stableToken {
                    VStack(spacing: 4) {
                        Text(token.emoji)
                            .font(.system(size: 48))
                        Text(token.rawValue)
                            .font(.title3.bold())
                            .foregroundStyle(.white)

                        // Confidence bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(token.color)
                                    .frame(width: geo.size.width * smoother.confidence)
                                    .animation(.linear(duration: 0.1), value: smoother.confidence)
                            }
                        }
                        .frame(width: 120, height: 6)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom, 8)
                }

                // ── Phrase suggestions ──
                if !phrasePredictor.suggestions.isEmpty {
                    VStack(spacing: 8) {
                        Text("Suggested phrases:")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))

                        ForEach(phrasePredictor.suggestions) { candidate in
                            Button {
                                speechSynth.speak(candidate.text)
                                phrasePredictor.clearBuffer()
                            } label: {
                                Text(candidate.text)
                                    .font(.body.bold())
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // ── Bottom controls ──
                HStack(spacing: 16) {
                    // Clear buffer
                    Button {
                        phrasePredictor.clearBuffer()
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Color.red.opacity(0.5))
                            .clipShape(Circle())
                    }

                    // Mic toggle
                    Button {
                        isListeningMode.toggle()
                        if isListeningMode {
                            speechRecognizer.startListening()
                        } else {
                            speechRecognizer.stopListening()
                        }
                    } label: {
                        Image(systemName: isListeningMode ? "mic.fill" : "mic")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(isListeningMode ? Color.green.opacity(0.8) : Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onReceive(cameraSession.$detectedHandPose) { pose in
            let token = pose.flatMap {
                HandPoseProcessor.process($0).flatMap {
                    GestureClassifier.classify($0)
                }
            }
            smoother.feed(token)
        }
        .onReceive(smoother.$confidence) { confidence in
            if confidence >= 1.0, let token = smoother.stableToken {
                if token != lastCommittedToken {
                    phrasePredictor.addToken(token)
                    lastCommittedToken = token
                }
            } else if confidence == 0 {
                lastCommittedToken = nil
            }
        }
        .onAppear { cameraSession.start() }
        .onDisappear { cameraSession.stop() }
    }
}
