import SwiftUI
import UserNotifications

// MARK: - Text input (name, companion name, feelings)

struct TextInputScreen: View {
    @ObservedObject var ob: Onboarding
    var showIllustration: Bool = true
    var illustration: String = ""
    var symbol: String = "heart.fill"
    let title: String
    var accents: [String] = []
    var subtitle: String? = nil
    let placeholder: String
    @Binding var text: String
    var buttonTitle: String = "Continue"
    var requireNonEmpty: Bool = true
    @FocusState private var focused: Bool

    private var valid: Bool {
        !requireNonEmpty || !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: ob.progress, centered: true,
            onBack: ob.back,
            primary: ButtonConfig(title: buttonTitle, enabled: valid, action: {
                focused = false; ob.next()
            })
        ) {
            VStack(spacing: PL.S.xl) {
                if showIllustration {
                    IllustrationSlot(name: illustration, fallbackSymbol: symbol, size: 150)
                }
                GoldHeadline(title, accents: accents, size: 32, alignment: .center)
                if let subtitle { PLSubtitle(subtitle, alignment: .center) }
                PLTextField(placeholder: placeholder, text: $text)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { if valid { focused = false; ob.next() } }
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { focused = true } }
    }
}

// MARK: - Social proof (reviews)

struct SocialProofScreen: View {
    @ObservedObject var ob: Onboarding
    let headline: String
    var accents: [String] = []
    var buttonTitle: String = "Continue"

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: buttonTitle, action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                VStack(spacing: PL.S.md) {
                    Eyebrow(text: "The #1 Prayer Habit App")
                    StarRow()
                    GoldHeadline(headline, accents: accents, size: 28, alignment: .center)
                    Text("+20,000 five-star reviews")
                        .font(.plSubtitle).foregroundColor(PL.C.textMuted)
                }
                VStack(spacing: PL.S.md) {
                    ReviewCard(text: "No joke, the only thing that's actually helped me pray consistently. The app lock is genius.", author: "GAME CHANGER")
                    ReviewCard(text: "Finally an app that gets it. I was so sick of my phone owning my mornings. Now God gets the first word.", author: "FINALLY!!")
                    ReviewCard(text: "It really lets me get closer to God. I'm so young and already growing in faith.", author: "Gia Faletto")
                }
            }
        }
    }
}

// MARK: - "You're in the right place" (reflects answers)

struct RightPlaceScreen: View {
    @ObservedObject var ob: Onboarding

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                IllustrationSlot(name: "chalice", fallbackSymbol: "cup.and.saucer.fill", size: 120)
                GoldHeadline("You're in the right place.", accents: ["right place"],
                             size: 30, alignment: .center)
                PLSubtitle("Tens of thousands have started with the same goals — and PrayerLock helped them get there.",
                           alignment: .center)
                VStack(spacing: PL.S.md) {
                    ReflectCard(eyebrow: "Your goal", title: ob.primaryGoal,
                                body_: "We'll guide you beyond surface-level prayer into a deeper, more intimate conversation with God.")
                    ReflectCard(eyebrow: "Where you're headed", title: ob.primaryThriving,
                                body_: "92% of people who start here form a daily prayer habit.")
                }
            }
        }
    }
}

// MARK: - How it works (3 steps)

struct HowItWorksScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Let's go", action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xxl) {
                VStack(alignment: .leading, spacing: PL.S.md) {
                    GoldHeadline("\(ob.firstName), thank you for your honesty.",
                                 accents: ["thank you"], size: 30)
                    PLSubtitle("PrayerLock is here to walk with you. Share how you're feeling, pray, and your apps unlock.")
                }
                VStack(alignment: .leading, spacing: PL.S.xl) {
                    NumberedStep(number: 1, text: "Share how you're feeling today")
                    NumberedStep(number: 2, text: "Pray")
                    NumberedStep(number: 3, text: "Unlock your apps")
                }
            }
        }
    }
}

// MARK: - Personalizing (fake loading)

struct PersonalizingScreen: View {
    @ObservedObject var ob: Onboarding
    @State private var progress: Double = 0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    private var caption: String {
        switch progress {
        case ..<0.4: return "Preparing your prayer life..."
        case ..<0.8: return "Preparing your first conversation with God..."
        default: return "Making sure this is tailored to you..."
        }
    }

    var body: some View {
        OnbScaffold(theme: .light, showBack: false, progress: nil) {
            VStack(spacing: PL.S.xxl) {
                VStack(spacing: PL.S.md) {
                    Eyebrow(text: "The #1 Prayer Habit App")
                    StarRow()
                }
                Text("\(Int(progress * 100))%")
                    .font(PL.F.serif(56, .regular))
                    .foregroundColor(PL.C.text)
                    .monospacedDigit()
                ProgressBar(value: progress).frame(height: 8)
                Text(caption)
                    .font(.plSubtitle).foregroundColor(PL.C.textMuted)
                    .multilineTextAlignment(.center)
                ReviewCard(text: "My relationship with God strengthened. I used to struggle just trying to pray — this app helped me.", author: "Gia Faletto")
                    .padding(.top, PL.S.lg)
            }
        }
        .onReceive(timer) { _ in
            if progress < 1 {
                progress = min(1, progress + 0.012)
            } else {
                ob.next()
            }
        }
    }
}

// MARK: - Community

struct CommunityScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xxl) {
                VStack(alignment: .leading, spacing: PL.S.md) {
                    GoldHeadline("Don't walk with God alone.", accents: ["God"], size: 30)
                    PLSubtitle("PrayerLock helps you pray before you scroll. The community keeps you encouraged, prayed for, and connected.")
                }
                VStack(alignment: .leading, spacing: PL.S.xl) {
                    FeatureRow(symbol: "hands.and.sparkles.fill", title: "Receive prayer",
                               subtitle: "Share what's heavy and let believers pray over you.")
                    FeatureRow(symbol: "sparkles", title: "See God move",
                               subtitle: "Read testimonies, verses, and honest moments.")
                    FeatureRow(symbol: "heart.fill", title: "Find encouragement",
                               subtitle: "A reminder that you're never alone.")
                }
            }
        }
    }
}

// MARK: - Prayer times setup

struct PrayerTimesSetupScreen: View {
    @ObservedObject var ob: Onboarding
    @ObservedObject var app = AppModel.shared
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                VStack(alignment: .leading, spacing: PL.S.md) {
                    GoldHeadline("Set your prayer times.", accents: ["prayer times"], size: 30)
                    PLSubtitle("Your apps lock at these times until you pray.")
                }
                TimeListEditor(times: $app.prayerTimes)
            }
        }
    }
}

// MARK: - 90-day plan (dark)

struct PlanScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .dark, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Start this plan", style: .invertedPill, action: ob.next)
        ) {
            VStack(spacing: PL.S.xxl) {
                GoldHeadline("90 days to build consistency.", accents: ["90 days"],
                             size: 30, base: PL.C.textOnInk, alignment: .center)
                VStack(alignment: .leading, spacing: PL.S.lg) {
                    HStack {
                        Text("90 day prayer journey")
                            .font(PL.F.sans(15, .semibold)).foregroundColor(PL.C.textOnInk)
                        Spacer()
                        Text("0% complete")
                            .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.gold)
                    }
                    ProgressBar(value: 0)
                    HStack {
                        Text(ob.firstName)
                            .font(PL.F.serifItalic(20)).foregroundColor(PL.C.textOnInk)
                        Spacer()
                        Text(Self.today)
                            .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textOnInkMuted)
                    }
                    .padding(.top, PL.S.sm)
                }
                .padding(PL.S.xl)
                .background(PL.C.inkCard)
                .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
            }
        }
    }
    static var today: String {
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"; return f.string(from: Date())
    }
}

// MARK: - Sign commitment

struct SignCommitmentScreen: View {
    @ObservedObject var ob: Onboarding
    @State private var lines: [[CGPoint]] = []
    @State private var current: [CGPoint] = []

    private var hasSigned: Bool { !lines.isEmpty || !current.isEmpty }

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", enabled: hasSigned, action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                GoldHeadline("Make your commitment.", accents: ["commitment"], size: 30)
                VStack(alignment: .leading, spacing: PL.S.md) {
                    commitmentRow("Seek God before my phone")
                    commitmentRow("Pray before scrolling")
                    commitmentRow("Be intentional with my screen time")
                    commitmentRow("Guard my heart and mind")
                }
                PLSubtitle("Sign as a reminder of the promise you're making.")
                signaturePad
            }
        }
    }

    private func commitmentRow(_ t: String) -> some View {
        HStack(spacing: PL.S.md) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(PL.C.gold)
            Text(t).font(PL.F.sans(16, .medium)).foregroundColor(PL.C.text)
        }
    }

    private var signaturePad: some View {
        Canvas { ctx, _ in
            for line in lines + [current] {
                var path = Path()
                if let first = line.first {
                    path.move(to: first)
                    for p in line.dropFirst() { path.addLine(to: p) }
                }
                ctx.stroke(path, with: .color(PL.C.text), lineWidth: 2.5)
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { current.append($0.location) }
                .onEnded { _ in lines.append(current); current = [] }
        )
        .overlay(alignment: .bottomTrailing) {
            if hasSigned {
                Button { lines = []; current = [] } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(PL.C.textMuted)
                        .padding(PL.S.md)
                }
            }
        }
    }
}

// MARK: - Notifications priming

struct NotificationsScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Allow", action: requestThenNext)
        ) {
            VStack(spacing: PL.S.xl) {
                GoldHeadline("Allow PrayerLock to send notifications.", accents: ["notifications"],
                             size: 28, alignment: .center)
                PLSubtitle("We use this so you can unblock your apps when it's time to pray.",
                           alignment: .center)
                mockNotification
                Button("Not now") { ob.next() }
                    .font(PL.F.sans(16, .semibold))
                    .foregroundColor(PL.C.textMuted)
            }
        }
    }

    private var mockNotification: some View {
        HStack(spacing: PL.S.md) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(PL.C.gold).frame(width: 38, height: 38)
                .overlay(Image(systemName: "bell.fill").foregroundColor(.white).font(.system(size: 16)))
            VStack(alignment: .leading, spacing: 2) {
                Text("Your apps are blocked!").font(PL.F.sans(15, .bold)).foregroundColor(PL.C.text)
                Text("Time to pray").font(PL.F.sans(14, .regular)).foregroundColor(PL.C.textMuted)
            }
            Spacer()
            Text("now").font(PL.F.sans(12, .regular)).foregroundColor(PL.C.textMuted)
        }
        .padding(PL.S.lg)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }

    private func requestThenNext() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async { ob.next() }
        }
    }
}
