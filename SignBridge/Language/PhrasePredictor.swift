import Foundation
import Combine

class PhrasePredictor: ObservableObject {
    @Published var suggestions: [PhraseCandidate] = []
    @Published var tokenBuffer: [GestureToken] = []
    
    private var tokenTimestamps: [Date] = []
    private let maxBufferAge: TimeInterval = 8.0

    func addToken(_ token: GestureToken) {
        pruneStaleTokens()
        // Avoid duplicate adjacent tokens
        if tokenBuffer.last == token { return }
        tokenBuffer.append(token)
        tokenTimestamps.append(Date())
        updateSuggestions()
    }

    func clearBuffer() {
        tokenBuffer = []
        tokenTimestamps = []
        suggestions = []
    }

    private func pruneStaleTokens() {
        let cutoff = Date().addingTimeInterval(-maxBufferAge)
        while let first = tokenTimestamps.first, first < cutoff {
            tokenBuffer.removeFirst()
            tokenTimestamps.removeFirst()
        }
    }

    private func updateSuggestions() {
        suggestions = PhraseDatabase.shared.lookup(tokens: tokenBuffer)
    }
}
