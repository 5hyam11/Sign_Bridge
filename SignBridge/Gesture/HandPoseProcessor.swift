import Vision
import CoreGraphics

struct NormalizedHand {
    let thumbTip: CGPoint
    let indexTip: CGPoint
    let middleTip: CGPoint
    let ringTip: CGPoint
    let pinkyTip: CGPoint
    let wrist: CGPoint
    let indexMCP: CGPoint
    let middleMCP: CGPoint
}

struct HandPoseProcessor {
    static func process(_ obs: VNHumanHandPoseObservation) -> NormalizedHand? {
        guard let points = try? obs.recognizedPoints(.all) else { return nil }

        func pt(_ key: VNHumanHandPoseObservation.JointName) -> CGPoint? {
            guard let p = points[key], p.confidence > 0.5 else { return nil }
            return CGPoint(x: p.location.x, y: 1 - p.location.y)
        }

        guard let wrist    = pt(.wrist),
              let thumbT   = pt(.thumbTip),
              let indexT   = pt(.indexTip),
              let middleT  = pt(.middleTip),
              let ringT    = pt(.ringTip),
              let pinkyT   = pt(.littleTip),
              let indexMCP = pt(.indexMCP),
              let midMCP   = pt(.middleMCP) else { return nil }

        let scale = distance(wrist, midMCP)
        guard scale > 0.01 else { return nil }

        func norm(_ p: CGPoint) -> CGPoint {
            CGPoint(x: (p.x - wrist.x) / scale,
                    y: (p.y - wrist.y) / scale)
        }

        return NormalizedHand(
            thumbTip:  norm(thumbT),
            indexTip:  norm(indexT),
            middleTip: norm(middleT),
            ringTip:   norm(ringT),
            pinkyTip:  norm(pinkyT),
            wrist:     .zero,
            indexMCP:  norm(indexMCP),
            middleMCP: norm(midMCP)
        )
    }

    static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}
