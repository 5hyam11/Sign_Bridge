import AVFoundation
import Combine

class SpeechSynthesizer: NSObject, ObservableObject {
    @Published var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                            didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                            didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
