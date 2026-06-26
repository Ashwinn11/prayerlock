import SwiftUI

/// The in-app prayer flow (and the model for the onboarding preview):
/// relationship check-in → feeling check-in → guided prayer → reflection → amen.
struct PrayerSessionView: View {
    var onClose: () -> Void
    @ObservedObject private var app = AppModel.shared

    enum Stage { case relationship, feeling, pray, reflect, amen }
    @State private var stage: Stage = .relationship
    @State private var relationship = 2
    @State private var feeling = 2
    @State private var reflection = ""
    @State private var remaining = 0
    @State private var timer: Timer?

    private var prayer: GuidedPrayer {
        PrayerLibrary.forMoods(feeling: feeling, relationship: relationship)
    }

    var body: some View {
        ZStack {
            PL.C.cream.ignoresSafeArea()
            switch stage {
            case .relationship:
                moodStage(title: "How's your relationship with God today?",
                          accents: ["relationship with God"],
                          stops: MoodStops.relationship, index: $relationship) {
                    stage = .feeling
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
    }

    // MARK: Close button
    private var closeButton: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(PL.C.text)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(PL.C.stroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
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
                GoldHeadline(title, accents: accents, size: 28, alignment: .center)
                EmojiSlider(stops: stops, index: index)
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
            BreathingRing(total: prayer.duration, remaining: remaining)
            Text(prayer.title)
                .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.text)
            TypewriterText(text: prayer.body, font: .plBody, color: PL.C.textMuted)
            ScriptureDarkCard(text: prayer.scripture, reference: prayer.reference,
                              italic: true, textColor: PL.C.gold, refColor: PL.C.textOnInk)
            Spacer(minLength: PL.S.lg)
            let done = remaining == 0
            Button { if done { goReflect() } } label: {
                Text(done ? "Continue" : "Be still · \(timeString)")
                    .font(.plButton)
                    .foregroundColor(done ? PL.C.gold : PL.C.gold.opacity(0.35))
                    .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                    .overlay(Capsule().stroke(
                        done ? PL.C.gold.opacity(0.5) : PL.C.gold.opacity(0.2),
                        lineWidth: 1.4))
            }
            .buttonStyle(.plain)
            .disabled(!done)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.top, PL.S.sm)
        .padding(.bottom, PL.S.lg)
    }

    // MARK: Reflection stage
    private var reflectStage: some View {
        VStack(spacing: PL.S.lg) {
            HStack {
                Button { goReflect(skipTimer: true) } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(PL.C.text)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(PL.C.stroke, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            VStack(alignment: .leading, spacing: PL.S.sm) {
                GoldHeadline("Sit with it", size: 28, alignment: .leading)
                PLSubtitle("Write a thought, a thanks, or a hope. Optional.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ReflectionEditor(text: $reflection, placeholder: "…")
                .frame(height: 220)
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

    // MARK: Amen stage
    private var amenStage: some View {
        VStack(spacing: PL.S.xl) {
            Spacer()
            IllustrationSlot(name: "hands-cross", fallbackSymbol: "hands.sparkles.fill", size: 150)
            GoldHeadline("Amen.", size: 34, alignment: .center)
            PLSubtitle("Your apps are unlocked for the rest of today. Carry the quiet with you.",
                       alignment: .center)
            Spacer()
            PrimaryButton(title: "Done", action: onClose)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.bottom, PL.S.lg)
    }

    // MARK: Logic
    private var timeString: String {
        String(format: "%d:%02d", remaining / 60, remaining % 60)
    }
    private func startPrayer() {
        stage = .pray
        remaining = prayer.duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remaining > 0 { remaining -= 1 } else { t.invalidate() }
        }
    }
    private func goReflect(skipTimer: Bool = false) {
        timer?.invalidate()
        withAnimation { stage = .reflect }
    }
    private func finish() {
        timer?.invalidate()
        let entry = PrayerLibrary.entry(for: prayer, reflection: reflection)
        app.completePrayer(entry: entry)
        withAnimation { stage = .amen }
    }
}

/// Breathing timer ring with countdown + "BREATHE".
struct BreathingRing: View {
    let total: Int
    let remaining: Int
    private var progress: Double {
        total > 0 ? Double(total - remaining) / Double(total) : 0
    }
    var body: some View {
        ZStack {
            Circle().stroke(PL.C.track, lineWidth: 3)
            Circle().trim(from: 0, to: progress)
                .stroke(PL.C.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            VStack(spacing: PL.S.xs) {
                Text(String(format: "%d:%02d", remaining / 60, remaining % 60))
                    .font(PL.F.serif(46, .regular)).foregroundColor(PL.C.text).monospacedDigit()
                Text("BREATHE").font(PL.F.sans(11, .bold)).tracking(2).foregroundColor(PL.C.textMuted)
            }
        }
        .frame(width: 210, height: 210)
    }
}
