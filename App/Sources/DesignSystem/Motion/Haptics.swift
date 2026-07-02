import SwiftUI
import CoreHaptics
import UIKit

/// Centralized, tuned haptics. Simple cues use UIKit generators (cheap, everywhere);
/// the signature `unlock()` swell is a bespoke CoreHaptics pattern — the physical payoff
/// of the prayer→unlock moment. All calls are no-ops on hardware without haptics.
extension PL {
    enum Haptics {
        /// A light tick — moving between discrete values (option select, slider detent, tab).
        static func selection() {
            let g = UISelectionFeedbackGenerator(); g.prepare(); g.selectionChanged()
        }
        /// A soft press — primary buttons, card taps.
        static func soft() { impact(.soft, intensity: 0.7) }
        /// A firmer press — commit actions.
        static func rigid() { impact(.rigid, intensity: 0.9) }
        /// A whisper — subtle confirmations.
        static func light() { impact(.light, intensity: 0.5) }

        /// Warm success — reflection saved, level up.
        static func success() {
            let g = UINotificationFeedbackGenerator(); g.prepare(); g.notificationOccurred(.success)
        }

        private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
            let g = UIImpactFeedbackGenerator(style: style); g.prepare(); g.impactOccurred(intensity: intensity)
        }

        /// The signature moment: a rising swell that blooms into a soft peak as the apps unlock.
        static func unlock() { HapticsEngine.shared.playUnlock() }

        /// Wake the CoreHaptics engine ahead of a known haptic moment (call on prayer start).
        static func prewarm() { HapticsEngine.shared.prewarm() }
    }
}

/// Owns the process-wide CHHapticEngine. Lazily created, auto-restarts after resets/stops.
final class HapticsEngine {
    static let shared = HapticsEngine()
    private var engine: CHHapticEngine?
    private var supported: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics }

    func prewarm() { ensureEngine() }

    private func ensureEngine() {
        guard supported, engine == nil else { return }
        engine = try? CHHapticEngine()
        engine?.isAutoShutdownEnabled = true
        engine?.resetHandler = { [weak self] in try? self?.engine?.start() }
        engine?.stoppedHandler = { _ in }
        try? engine?.start()
    }

    /// Continuous 0.6s intensity ramp (0.2 → 1.0) with two transient sparkles at the crest.
    func playUnlock() {
        guard supported else { return }
        ensureEngine()
        guard let engine else { return }
        let swell = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.85),
                .init(parameterID: .hapticSharpness, value: 0.35),
            ],
            relativeTime: 0, duration: 0.6)
        let ramp = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: 0.15),
                .init(relativeTime: 0.45, value: 1.0),
                .init(relativeTime: 0.6, value: 0.7),
            ], relativeTime: 0)
        let sparkle1 = CHHapticEvent(eventType: .hapticTransient, parameters: [
            .init(parameterID: .hapticIntensity, value: 0.9),
            .init(parameterID: .hapticSharpness, value: 0.6),
        ], relativeTime: 0.42)
        let sparkle2 = CHHapticEvent(eventType: .hapticTransient, parameters: [
            .init(parameterID: .hapticIntensity, value: 0.6),
            .init(parameterID: .hapticSharpness, value: 0.8),
        ], relativeTime: 0.56)
        guard let pattern = try? CHHapticPattern(events: [swell, sparkle1, sparkle2], parameterCurves: [ramp]),
              let player = try? engine.makePlayer(with: pattern) else { return }
        try? engine.start()
        try? player.start(atTime: 0)
    }
}
