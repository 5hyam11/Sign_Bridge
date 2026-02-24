import AVFoundation
import Vision
import Combine

class CameraSession: NSObject, ObservableObject {
    let previewLayer = AVCaptureVideoPreviewLayer()
    @Published var detectedHandPose: VNHumanHandPoseObservation?

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let processingQueue = DispatchQueue(label: "handpose.queue", qos: .userInteractive)

    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 1
        setupSession()
    }

    private func setupSession() {
        session.sessionPreset = .hd1280x720
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        session.addOutput(videoOutput)
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    func start() {
        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    func stop() {
        session.stopRunning()
    }
}

extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .leftMirrored)
        try? handler.perform([handPoseRequest])
        DispatchQueue.main.async {
            self.detectedHandPose = self.handPoseRequest.results?.first
        }
    }
}   
