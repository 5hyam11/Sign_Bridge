import Foundation
import Combine

class GestureSmoother: ObservableObject {
    @Published var stableToken: GestureToken? = nil
    @Published var confidence: Double = 0.0

    private var buffer: [GestureToken?] = Array(repeating: nil, count: 20)
    private var bufferIndex = 0
    private var holdCounter = 0
    private let holdThreshold = 15

    func feed(_ token: GestureToken?) {
        buffer[bufferIndex % buffer.count] = token
        bufferIndex += 1

        let counts = buffer.compactMap { $0 }
            .reduce(into: [:]) { $0[$1, default: 0] += 1 }

        let dominant = counts.max(by: { $0.value < $1.value })

        guard let winner = dominant,
              Double(winner.value) / Double(buffer.count) > 0.5 else {
            confidence = 0
            stableToken = nil
            holdCounter = 0
            return
        }

        if winner.key == stableToken {
            holdCounter = min(holdCounter + 1, holdThreshold)
        } else {
            holdCounter = 0
            stableToken = winner.key
        }

        confidence = Double(holdCounter) / Double(holdThreshold)
    }
}
