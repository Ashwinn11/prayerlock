import SwiftUI

/// Swift front-ends for `Shaders.metal`. Each effect is a `TimelineView(.animation)`-driven
/// `visualEffect` so it animates without a `GeometryReader`, and pauses (freezes) under
/// Reduce Motion. Time is wrapped to an hour to keep float precision high.
private func shaderTime(_ date: Date) -> Float {
    Float(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600))
}

// MARK: paperGrain — warm animated paper texture + vignette

private struct PaperGrain: ViewModifier {
    var intensity: Double = 1
    // Paper fibers are a *fixed* texture (premium stock), not shimmering film grain, so this
    // renders once with a constant seed — no per-frame churn. The mesh supplies the motion.
    func body(content: Content) -> some View {
        content.visualEffect { view, proxy in
            view.colorEffect(ShaderLibrary.paperGrain(
                .float2(proxy.size), .float(0), .float(Float(intensity))))
        }
    }
}

// MARK: auroraBreath — living warm field that breathes with the prayer cadence

private struct AuroraBreath: ViewModifier {
    /// Fixed breath level (0…1); ignored when `cycle` is set.
    var breath: Double = 0.5
    /// When set, the breath auto-cycles on this period (seconds): inhale to 1, exhale to 0.
    var cycle: Double? = nil
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduce)) { ctx in
            let t = shaderTime(ctx.date)
            let b: Double = {
                guard let cycle, !reduce else { return breath }
                let phase = ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle)
                return 0.5 - 0.5 * Foundation.cos(2 * .pi * phase / cycle)
            }()
            content.visualEffect { view, proxy in
                view.colorEffect(ShaderLibrary.auroraBreath(
                    .float2(proxy.size), .float(t), .float(Float(b))))
            }
        }
    }
}

// MARK: godRays — additive warm rays from a source point

private struct GodRays: ViewModifier {
    var source: UnitPoint = .init(x: 0.5, y: 0.18)
    var strength: Double = 1
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduce)) { ctx in
            let t = shaderTime(ctx.date)
            content.visualEffect { view, proxy in
                view.colorEffect(ShaderLibrary.godRays(
                    .float2(proxy.size), .float(t),
                    .float2(Float(source.x), Float(source.y)), .float(Float(strength))))
            }
        }
    }
}

// MARK: goldFoil — gild only the gold pixels of a headline (accent shimmer)

private struct GoldFoil: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduce)) { ctx in
            let t = shaderTime(ctx.date)
            content.visualEffect { view, proxy in
                view.colorEffect(ShaderLibrary.goldFoil(.float2(proxy.size), .float(t)))
            }
        }
    }
}

// MARK: shimmerSweep — moving highlight band across a filled shape (CTAs)

private struct ShimmerSweep: ViewModifier {
    var active: Bool = true
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        if active && !reduce {
            TimelineView(.animation) { ctx in
                let t = shaderTime(ctx.date)
                content.visualEffect { view, proxy in
                    view.colorEffect(ShaderLibrary.shimmerSweep(.float2(proxy.size), .float(t)))
                }
            }
        } else {
            content
        }
    }
}

// MARK: unlockBloom — expanding warm ring + glow (Amen payoff)

private struct UnlockBloom: ViewModifier {
    var progress: Double
    func body(content: Content) -> some View {
        content.visualEffect { view, proxy in
            view.colorEffect(ShaderLibrary.unlockBloom(
                .float2(proxy.size), .float(Float(progress))))
        }
    }
}

// MARK: liquidRefraction — radial ripple distortion (state-change / unlock)

private struct LiquidRefraction: ViewModifier {
    var center: UnitPoint = .center
    var amount: Double            // 0 = flat; ramp up then down to fire a ripple
    @Environment(\.accessibilityReduceMotion) private var reduce
    func body(content: Content) -> some View {
        if amount <= 0.001 || reduce {
            content
        } else {
            TimelineView(.animation) { ctx in
                let t = shaderTime(ctx.date)
                content.visualEffect { view, proxy in
                    view.distortionEffect(
                        ShaderLibrary.liquidRefraction(
                            .float2(proxy.size), .float(t),
                            .float2(Float(center.x), Float(center.y)), .float(Float(amount))),
                        maxSampleOffset: CGSize(width: 24, height: 24))
                }
            }
        }
    }
}

// MARK: - Ergonomic View API

extension View {
    /// Subtle animated paper grain + vignette. Apply to a full-screen background fill.
    func plPaperGrain(intensity: Double = 1) -> some View { modifier(PaperGrain(intensity: intensity)) }
    /// Living warm field that expands/contracts with `breath` (0…1). Prayer background.
    func plAuroraBreath(breath: Double) -> some View { modifier(AuroraBreath(breath: breath)) }
    /// Aurora whose breath auto-cycles on `cycle` seconds (inhale→exhale). Prayer background.
    func plAuroraBreathing(cycle: Double = 8) -> some View { modifier(AuroraBreath(cycle: cycle)) }
    /// Additive warm god-rays from `source`. Dark insight beats / Amen.
    func plGodRays(source: UnitPoint = .init(x: 0.5, y: 0.18), strength: Double = 1) -> some View {
        modifier(GodRays(source: source, strength: strength))
    }
    /// Gild the gold accent words of a headline with a slow moving sheen.
    func plGoldFoil() -> some View { modifier(GoldFoil()) }
    /// Sweep a highlight band across a filled shape (CTA). No-op under Reduce Motion.
    func plShimmer(active: Bool = true) -> some View { modifier(ShimmerSweep(active: active)) }
    /// Expanding warm bloom keyed to `progress` (0…1). The unlock payoff visual.
    func plUnlockBloom(progress: Double) -> some View { modifier(UnlockBloom(progress: progress)) }
    /// Radial ripple refraction; drive `amount` from 0→peak→0 to fire once.
    func plLiquidRipple(center: UnitPoint = .center, amount: Double) -> some View {
        modifier(LiquidRefraction(center: center, amount: amount))
    }
}
