import SwiftUI

// MARK: - Pressable button style (spring scale + soft haptic)

/// Any `Button` using this style presses with a springy scale and a soft haptic.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    var haptic: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(PL.Motion.pop, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && haptic { PL.Haptics.soft() }
            }
    }
}

extension ButtonStyle where Self == PressableStyle {
    static var pressable: PressableStyle { PressableStyle() }
    static func pressable(scale: CGFloat, haptic: Bool = true) -> PressableStyle {
        PressableStyle(scale: scale, haptic: haptic)
    }
}

// MARK: - Warm glow

private struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    var active: Bool
    func body(content: Content) -> some View {
        content
            .shadow(color: active ? color.opacity(0.55) : .clear, radius: radius)
            .shadow(color: active ? color.opacity(0.30) : .clear, radius: radius * 2)
            .animation(PL.Motion.smooth, value: active)
    }
}

extension View {
    /// A soft warm halo — light-emitting surfaces (active buttons, rings, unlock).
    func plGlow(_ color: Color = PL.C.goldGlow, radius: CGFloat = 12, active: Bool = true) -> some View {
        modifier(GlowModifier(color: color, radius: radius, active: active))
    }
}

// MARK: - Rolling number (odometer)

/// An integer that rolls/pops when it changes — stats, streak, level, percentages.
struct RollingNumber: View {
    let value: Int
    var font: Font = PL.F.serif(28, .regular)
    var color: Color = PL.C.text
    var body: some View {
        Text("\(value)")
            .font(font)
            .foregroundColor(color)
            .monospacedDigit()
            .contentTransition(.numericText(value: Double(value)))
            .animation(PL.Motion.bounce, value: value)
    }
}

// MARK: - Staggered reveal

private struct RevealModifier: ViewModifier {
    var index: Int
    var travel: CGFloat
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : (reduce ? 0 : travel))
            // Quick ease, tight stagger — a settle, never a queue. Content is readable almost
            // immediately; the screen push carries the real entrance.
            .onAppear {
                withAnimation(.easeOut(duration: 0.18).delay(PL.Motion.stagger(index))) {
                    shown = true
                }
            }
    }
}

extension View {
    /// A light fade + tiny rise, tightly staggered by `index`. Reserved for list-y content;
    /// the screen transition itself is the primary entrance, so this stays fast and subtle.
    func plReveal(_ index: Int = 0, travel: CGFloat = 6) -> some View {
        modifier(RevealModifier(index: index, travel: travel))
    }
}

// MARK: - Sparkle emitter (the unlock payoff)

/// A single warm burst of gold sparks radiating from the center — plays once on appear.
/// Deterministic per-particle "randomness" (hash of index) so it renders identically every
/// time; skipped entirely under Reduce Motion.
struct SparkleEmitter: View {
    var count: Int = 26
    var duration: Double = 2.6
    @State private var start = Date()
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        if reduce {
            EmptyView()
        } else {
            TimelineView(.animation) { ctx in
                Canvas { g, size in
                    let t = ctx.date.timeIntervalSince(start)
                    guard t >= 0, t < duration else { return }
                    let c = CGPoint(x: size.width / 2, y: size.height / 2)
                    for i in 0..<count {
                        let h0 = hash(i, 1), h1 = hash(i, 2), h2 = hash(i, 3), h3 = hash(i, 4)
                        let life = duration * (0.5 + 0.5 * h0)
                        let p = t / life
                        guard p < 1 else { continue }
                        let ease = 1 - pow(1 - p, 3)                      // easeOutCubic
                        let angle = h1 * 2 * .pi
                        let dist = (26 + 96 * h2) * ease
                        let pos = CGPoint(x: c.x + Foundation.cos(angle) * dist,
                                          y: c.y + Foundation.sin(angle) * dist - 26 * p)  // drift up
                        let alpha = (1 - p) * (0.45 + 0.55 * h3)
                        let r = (1.4 + 2.4 * h3) * (1 - 0.4 * p)
                        var ctx2 = g
                        ctx2.opacity = alpha
                        let rect = CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)
                        ctx2.fill(Path(ellipseIn: rect), with: .color(i % 4 == 0 ? PL.C.goldHi : PL.C.gold))
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    /// Deterministic 0…1 pseudo-random from (index, salt).
    private func hash(_ i: Int, _ salt: Int) -> Double {
        let x = sin(Double(i * 127 + salt * 311) * 12.9898) * 43758.5453
        return x - x.rounded(.down)
    }
}

// MARK: - Floating illustration (entrance spring + gentle idle float)

/// Drop-in replacement for `IllustrationSlot` on hero screens: springs in on appear and
/// then breathes with a slow vertical float. Honors Reduce Motion (no float).
struct FloatingIllustration: View {
    let name: String
    var symbol: String = "cross.fill"
    var size: CGFloat = 168
    var glow: Bool = false

    @State private var floatUp = false
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        // Illustration is present immediately (it rides the screen push); the only motion is
        // a slow, ambient vertical float — never a blocking entrance the user waits on.
        IllustrationSlot(name: name, fallbackSymbol: symbol, size: size)
            .offset(y: reduce ? 0 : (floatUp ? -6 : 6))
            .plGlow(PL.C.goldGlow.opacity(0.5), radius: 24, active: glow)
            .onAppear {
                guard !reduce else { return }
                withAnimation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true)) {
                    floatUp = true
                }
            }
    }
}
