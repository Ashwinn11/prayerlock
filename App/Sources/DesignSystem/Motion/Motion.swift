import SwiftUI

/// The app's single spring vocabulary. Every animation is drawn from here so motion
/// feels authored, not accidental. Tuned as a family: shared personality, different energy.
extension PL {
    enum Motion {
        /// Lively overshoot — selections, appearing cards, companion ring.
        static let bounce   = Animation.spring(response: 0.50, dampingFraction: 0.62)
        /// Settles fast with a whisper of overshoot — most state changes.
        static let smooth   = Animation.spring(response: 0.42, dampingFraction: 0.90)
        /// Quick and crisp — toggles, small value changes.
        static let snappy   = Animation.spring(response: 0.30, dampingFraction: 0.82)
        /// Slow, no overshoot — ambient / breathing / reveal-in-place.
        static let gentle   = Animation.spring(response: 0.70, dampingFraction: 1.0)
        /// Punchy press feedback — button/row tap scale.
        static let pop      = Animation.spring(response: 0.26, dampingFraction: 0.58)
        /// Signature page push between onboarding/flow screens. Snappy, minimal tail — the
        /// screen should land fast and its content be readable immediately.
        static let screen   = Animation.spring(response: 0.40, dampingFraction: 0.90)
        /// Follows a finger 1:1 during a drag, then eases out on release.
        static let track    = Animation.interactiveSpring(response: 0.28, dampingFraction: 0.86, blendDuration: 0.1)

        /// True when the user has asked the system to minimize motion. Read this in
        /// imperative code paths (`withAnimation`, timers) where `@Environment` isn't handy.
        static var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }

        /// Reduce-Motion-safe resolver: swaps any spring for a short crossfade-friendly
        /// ease when the user minimizes motion. Use for structural / large-travel motion.
        static func resolve(_ animation: Animation) -> Animation {
            reduceMotion ? .easeInOut(duration: 0.2) : animation
        }

        /// Staggered per-index delay for cascade reveals. Deliberately small so lists never
        /// make the user *wait* — a whisper of life, not a queue. 0 under Reduce Motion.
        static func stagger(_ index: Int, step: Double = 0.022, cap: Double = 0.11) -> Double {
            reduceMotion ? 0 : min(Double(index) * step, cap)
        }
    }
}

extension View {
    /// Apply a PL motion token to a value change, automatically honoring Reduce Motion.
    func plAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.animation(PL.Motion.resolve(animation), value: value)
    }
}

/// Reduce-Motion-safe `withAnimation`.
@discardableResult
func withPLAnimation<Result>(_ animation: Animation = PL.Motion.smooth,
                             _ body: () throws -> Result) rethrows -> Result {
    try withAnimation(PL.Motion.resolve(animation), body)
}
