import SwiftUI

/// A slowly drifting `MeshGradient` warm field (iOS 18) + animated paper grain. Gives every
/// screen subtle living depth instead of a flat fill. Light and dark ("insight") variants.
struct AmbientMesh: View {
    var theme: ScreenTheme = .light
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        TimelineView(.animation(paused: reduce)) { ctx in
            let t = Float(ctx.date.timeIntervalSinceReferenceDate)
            MeshGradient(width: 3, height: 3, points: points(t), colors: colors)
                // Overscan: mesh points are geometry, so any boundary motion would bend the
                // painted edge inward. The boundary is pinned below, and this 12% bleed
                // guarantees the edge can never become visible regardless.
                .scaleEffect(1.12)
                .ignoresSafeArea()
        }
    }

    /// ALL 8 boundary points are pinned at exact 0 / 0.5 / 1 — only the CENTER point drifts.
    /// Displacing boundary points bends the mesh's outer edge into a visible curve (looks like
    /// a warped sheet), so the boundary must never move.
    private func points(_ t: Float) -> [SIMD2<Float>] {
        let cx = 0.5 + sin(t * 0.066 + 0.5) * 0.06
        let cy = 0.5 + sin(t * 0.084 + 3.0) * 0.05
        return [
            SIMD2(0, 0),   SIMD2(0.5, 0), SIMD2(1, 0),
            SIMD2(0, 0.5), SIMD2(cx, cy), SIMD2(1, 0.5),
            SIMD2(0, 1),   SIMD2(0.5, 1), SIMD2(1, 1),
        ]
    }

    /// Tonal stops kept within a whisper (~3% luminance) so the drift reads as ambient light
    /// moving across paper — never as folds or curvature.
    private var colors: [Color] {
        theme == .light
        ? [Color(hex: 0xF7F2E9), Color(hex: 0xF8F3EA), Color(hex: 0xF5F0E7),
           Color(hex: 0xF4EFE6), Color(hex: 0xF8F4EB), Color(hex: 0xF3EEE4),
           Color(hex: 0xF1EBE0), Color(hex: 0xF3EDE3), Color(hex: 0xF0EADE)]
        : [PL.C.ink, Color(hex: 0x38342D), PL.C.ink,
           Color(hex: 0x39342D), PL.C.inkRaised, Color(hex: 0x373229),
           PL.C.ink, Color(hex: 0x36322B), PL.C.ink]
    }
}

/// Full-screen ambient background = drifting mesh + paper grain.
struct ScreenBackground: View {
    var theme: ScreenTheme = .light
    var body: some View {
        AmbientMesh(theme: theme)
            .plPaperGrain(intensity: theme == .light ? 0.8 : 0.6)
            .ignoresSafeArea()
    }
}

extension View {
    /// Replace a flat `theme.background` fill with the living ambient background.
    func plScreen(_ theme: ScreenTheme = .light) -> some View {
        background(ScreenBackground(theme: theme))
    }
}
