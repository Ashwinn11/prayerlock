import SwiftUI

/// The in-app prayer flow (and the model for the onboarding preview):
/// relationship check-in → feeling check-in → guided prayer → reflection → amen.
///
/// The pray stage breathes: the aurora background and the ring expand/contract on the
/// same 8-second cadence. The amen stage is the payoff — god-rays, an unlock bloom,
/// a burst of gold sparks, and the signature rising-swell unlock haptic.
struct PrayerSessionView: View {
    var onClose: () -> Void
    @ObservedObject private var app = AppModel.shared
    @Environment(\.accessibilityReduceMotion) private var reduce

    enum Stage { case relationship, feeling, pray, reflect, amen }
    @State private var stage: Stage = .relationship
    @State private var relationship = 2
    @State private var feeling = 2
    @State private var reflection = ""
    @State private var remaining = 0
    @State private var timer: Timer?
    @State private var amenAt: Date?

    /// Shared breath cadence (seconds) for the aurora + ring.
    private let breathCycle: Double = 8

    private var prayer: GuidedPrayer {
        PrayerLibrary.forMoods(feeling: feeling, relationship: relationship)
    }

    var body: some View {
        ZStack {
            background
            stageBody
                .plContent()
        }
    }

    // MARK: Stage container + transitions

    @ViewBuilder private var stageBody: some View {
        Group {
            switch stage {
            case .relationship:
                moodStage(title: "How's your relationship with God today?",
                          accents: ["relationship with God"],
                          stops: MoodStops.relationship, index: $relationship) {
                    setStage(.feeling)
                }
            case .feeling:
                moodStage(title: "How are you feeling today?", accents: ["feeling"],
                          stops: MoodStops.feeling, index: $feeling) {
                    startPrayer()
                }
            case .pray:
                prayStage
            case .reflect:
                reflectStage
            case .amen:
                amenStage
            }
        }
        .transition(stageTransition)
    }

    private var stageTransition: AnyTransition {
        if reduce { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.98)),
            removal: .move(edge: .leading).combined(with: .opacity))
    }

    private func setStage(_ s: Stage) {
        withPLAnimation(PL.Motion.screen) { stage = s }
    }

    // MARK: Backgrounds — each stage gets its own atmosphere

    @ViewBuilder private var background: some View {
        switch stage {
        case .pray:
            ScreenBackground(theme: .light)
                .plAuroraBreathing(cycle: breathCycle)
                .transition(.opacity)
        case .amen:
            amenBackground
                .transition(.opacity)
        default:
            ScreenBackground(theme: .light)
                .transition(.opacity)
        }
    }

    /// God-rays fade in as the unlock bloom expands outward — the visual half of the payoff.
    private var amenBackground: some View {
        TimelineView(.animation) { ctx in
            let p = amenAt.map { min(1, ctx.date.timeIntervalSince($0) / 1.6) } ?? 0
            ScreenBackground(theme: .light)
                .plGodRays(source: .init(x: 0.5, y: 0.32), strength: 0.7 * p)
                .plUnlockBloom(progress: reduce ? 1 : p)
        }
    }

    // MARK: Close button
    private var closeButton: some View {
        HStack {
            Button(action: { PL.Haptics.light(); onClose() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(PL.C.text)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(PL.C.stroke, lineWidth: 1))
            }
            .buttonStyle(.pressable)
            Spacer()
        }
    }

    // MARK: Mood stages
    private func moodStage(title: String, accents: [String], stops: [MoodStop],
                           index: Binding<Int>, next: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            closeButton
            Spacer()
            VStack(spacing: PL.S.xxxl) {
                GoldHeadline(title, accents: accents, size: 28, alignment: .center, foil: true)
                    .plReveal(0)
                EmojiSlider(stops: stops, index: index)
                    .plReveal(1)
            }
            Spacer()
            PrimaryButton(title: "Continue", action: next)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.top, PL.S.sm)
        .padding(.bottom, PL.S.lg)
    }

    // MARK: Pray stage (breathing ring + typewriter prayer)
    private var prayStage: some View {
        VStack(spacing: PL.S.xl) {
            Eyebrow(text: "A Moment of Prayer")
                .plReveal(0)
            BreathingRing(total: prayer.duration, remaining: remaining, cycle: breathCycle)
                .plReveal(1)
            Text(prayer.title)
                .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.text)
                .plReveal(2)
            TypewriterText(text: prayer.body, font: .plBody, color: PL.C.textMuted)
            ScriptureDarkCard(text: prayer.scripture, reference: prayer.reference,
                              italic: true, textColor: PL.C.gold, refColor: PL.C.textOnInk)
                .plReveal(3)
            Spacer(minLength: PL.S.lg)
            let done = remaining == 0
            if done {
                PrimaryButton(title: "Continue") { goReflect() }
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            } else {
                Text("Be still · \(timeString)")
                    .font(.plButton)
                    .monospacedDigit()
                    .foregroundColor(PL.C.gold.opacity(0.45))
                    .contentTransition(.numericText())
                    .animation(PL.Motion.snappy, value: remaining)
                    .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                    .overlay(Capsule().stroke(PL.C.gold.opacity(0.2), lineWidth: 1.4))
            }
        }
        .animation(PL.Motion.bounce, value: remaining == 0)
        .padding(.horizontal, PL.L.margin)
        .padding(.top, PL.S.sm)
        .padding(.bottom, PL.S.lg)
    }

    // MARK: Reflection stage
    private var reflectStage: some View {
        VStack(spacing: PL.S.lg) {
            closeButton
            VStack(alignment: .leading, spacing: PL.S.sm) {
                GoldHeadline("Sit with it", size: 28, alignment: .leading)
                    .plReveal(0)
                PLSubtitle("Write a thought, a thanks, or a hope. Optional.")
                    .plReveal(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ReflectionEditor(text: $reflection, placeholder: "…")
                .frame(height: 220)
                .plReveal(2)
            Spacer()
            PrimaryButton(title: "Save & unlock") { finish() }
            Button("Skip") { finish() }
                .font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.textMuted)
                .padding(.top, PL.S.xs)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.top, PL.S.sm)
        .padding(.bottom, PL.S.lg)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.gold)
            }
        }
    }

    // MARK: Amen stage — the payoff
    private var amenStage: some View {
        VStack(spacing: PL.S.xl) {
            Spacer()
            ZStack {
                SparkleEmitter(count: 26, duration: 2.6)
                    .frame(width: 280, height: 280)
                FloatingIllustration(name: "hands-cross", symbol: "hands.sparkles.fill",
                                     size: 150, glow: true)
            }
            GoldHeadline("Amen.", accents: ["Amen."], size: 40, alignment: .center, foil: true)
                .plReveal(1)
            PLSubtitle("Your apps are unlocked for the rest of today. Carry the quiet with you.",
                       alignment: .center)
                .plReveal(2)
            Spacer()
            PrimaryButton(title: "Done", action: onClose)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.bottom, PL.S.lg)
        .onAppear { PL.Haptics.unlock() }
    }

    // MARK: Logic
    private var timeString: String {
        String(format: "%d:%02d", remaining / 60, remaining % 60)
    }
    private func startPrayer() {
        PL.Haptics.prewarm()   // wake the engine so the unlock swell fires instantly later
        setStage(.pray)
        remaining = prayer.duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remaining > 0 { remaining -= 1 } else { t.invalidate() }
        }
    }
    private func goReflect(skipTimer: Bool = false) {
        timer?.invalidate()
        setStage(.reflect)
    }
    private func finish() {
        timer?.invalidate()
        let entry = PrayerLibrary.entry(for: prayer, reflection: reflection)
        app.completePrayer(entry: entry)
        amenAt = Date()
        setStage(.amen)
    }
}

/// Countdown ring that physically breathes on the shared cadence: a warm halo and the
/// ring itself swell on the inhale and settle on the exhale, while "BREATHE IN/OUT"
/// crossfades at each turn. The countdown stays steady for readability.
struct BreathingRing: View {
    let total: Int
    let remaining: Int
    var cycle: Double = 8
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduce
    private var diameter: CGFloat { sizeClass == .regular ? 270 : 210 }
    private var progress: Double {
        total > 0 ? Double(total - remaining) / Double(total) : 0
    }

    var body: some View {
        TimelineView(.animation(paused: reduce)) { ctx in
            let phase = ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle)
            let breath = reduce ? 0.5 : 0.5 - 0.5 * Foundation.cos(2 * .pi * phase / cycle)
            let inhale = phase < cycle / 2
            let cueFade = reduce ? 1.0 : min(1, abs(Foundation.sin(2 * .pi * phase / cycle)) * 3)

            ZStack {
                // Breathing halo behind the ring.
                Circle()
                    .fill(RadialGradient(colors: [PL.C.goldGlow.opacity(0.22), .clear],
                                         center: .center, startRadius: 0, endRadius: diameter * 0.62))
                    .scaleEffect(0.85 + 0.25 * breath)
                Group {
                    Circle().stroke(PL.C.track, lineWidth: 3)
                    Circle().trim(from: 0, to: progress)
                        .stroke(PL.C.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                        .shadow(color: PL.C.goldGlow.opacity(0.25 + 0.35 * breath), radius: 8)
                }
                .scaleEffect(0.94 + 0.06 * breath)
                VStack(spacing: PL.S.xs) {
                    Text(String(format: "%d:%02d", remaining / 60, remaining % 60))
                        .font(PL.F.serif(46, .regular)).foregroundColor(PL.C.text).monospacedDigit()
                        .contentTransition(.numericText(countsDown: true))
                        .animation(PL.Motion.snappy, value: remaining)
                    Text(reduce ? "BREATHE" : (inhale ? "BREATHE IN" : "BREATHE OUT"))
                        .font(PL.F.sans(11, .bold)).tracking(2).foregroundColor(PL.C.textMuted)
                        .opacity(cueFade)
                }
            }
            .frame(width: diameter, height: diameter)
        }
    }
}
