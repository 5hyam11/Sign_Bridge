import CoreGraphics

struct GestureClassifier {
    private static let threshold: CGFloat = 0.8

    static func classify(_ h: NormalizedHand) -> GestureToken? {
        let indexUp  = h.indexTip.y  > threshold
        let middleUp = h.middleTip.y > threshold
        let ringUp   = h.ringTip.y   > threshold
        let pinkyUp  = h.pinkyTip.y  > threshold
        let thumbOut = h.thumbTip.x  < -0.5

        let allCurled = !indexUp && !middleUp && !ringUp && !pinkyUp

        // HELLO — all four fingers up, thumb out
        if indexUp && middleUp && ringUp && pinkyUp && thumbOut { return .hello }

        // STOP — all four fingers up, thumb tucked
        if indexUp && middleUp && ringUp && pinkyUp && !thumbOut { return .stop }

        // YES — fist, all curled, thumb tucked
        if allCurled && !thumbOut { return .yes }

        // HELP — thumb up, all others curled
        if allCurled && thumbOut { return .help }

        // NO — index + middle up only
        if indexUp && middleUp && !ringUp && !pinkyUp { return .no }

        // THANK YOU — index only up
        if indexUp && !middleUp && !ringUp && !pinkyUp { return .thankYou }

        // PLEASE — pinky only up
        if !indexUp && !middleUp && !ringUp && pinkyUp { return .please }

        // MORE — index + pinky up (horns)
        if indexUp && !middleUp && !ringUp && pinkyUp { return .more }

        return nil
    }
}
