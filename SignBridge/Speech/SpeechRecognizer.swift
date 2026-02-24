import Speech
import Combine

class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var isListening = false

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        recognizer = SFSpeechRecognizer(locale: .current)
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func startListening() {
        guard let recognizer, recognizer.isAvailable else { return }
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        request?.requiresOnDeviceRecognition = true

        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        try? audioEngine.start()
        isListening = true

        task = recognizer.recognitionTask(with: request!) { [weak self] result, error in
            if let result {
                DispatchQueue.main.async {
                    self?.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || result?.isFinal == true {
                self?.stopListening()
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        isListening = false
    }
}
