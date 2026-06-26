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
                GoldHeadline(title, accents: accents, size: 28, alignment: .center)
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
            theme: .dark, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Let's go", style: .plainOnInk, action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                IllustrationSlot(name: "hand-dove", fallbackSymbol: "bird.fill", size: 150)
                VStack(spacing: PL.S.md) {
                    GoldHeadline("\(ob.firstName) , thank you for your honesty.",
                                 size: 28, base: PL.C.textOnInk, alignment: .center)
                    PLSubtitle("PrayerLock is here to walk with you. Share how you're feeling, pray, and your apps unlock.",
                               alignment: .center, color: PL.C.textOnInkMuted)
                }
                VStack(alignment: .leading, spacing: PL.S.xl) {
                    NumberedStep(number: 1, text: "Share how you're feeling today", theme: .dark)
                    NumberedStep(number: 2, text: "Pray", theme: .dark)
                    NumberedStep(number: 3, text: "Unlock your apps", theme: .dark)
                }
                .padding(.top, PL.S.sm)
            }
        }
    }
}

// MARK: - Personalizing (fake loading)

struct PersonalizingScreen: View {
    @ObservedObject var ob: Onboarding
    @State private var progress: Double = 0
    @State private var advanced = false
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let dotCount = 7

    private var caption: String {
        switch progress {
        case ..<0.4: return "Preparing your prayer life..."
        case ..<0.8: return "Preparing your first conversation with God..."
        default: return "Making sure this is tailored to you..."
        }
    }
    private var filledDots: Int { min(dotCount, Int((progress * Double(dotCount)).rounded())) }

    var body: some View {
        OnbScaffold(theme: .light, showBack: false, progress: nil, centered: true) {
            VStack(spacing: PL.S.xl) {
                laurelBadge
                Text("\(Int(progress * 100))%")
                    .font(PL.F.serif(64, .regular))
                    .foregroundColor(PL.C.text)
                    .monospacedDigit()
                ProgressBar(value: progress).frame(height: 8)
                dots
                Text(caption)
                    .font(PL.F.serif(22, .regular)).foregroundColor(PL.C.text)
                    .multilineTextAlignment(.center)
                ReviewCard(text: "My relationship with God strengthened. I used to struggle just trying to pray — this app helped me.", author: "Gia Faletto")
                    .padding(.top, PL.S.sm)
            }
        }
        .onReceive(timer) { _ in
            if progress < 1 {
                progress = min(1, progress + 0.012)
            } else if !advanced {
                advanced = true
                ob.next()
            }
        }
    }

    private var laurelBadge: some View {
        HStack(spacing: PL.S.sm) {
            Image(systemName: "laurel.leading").foregroundColor(PL.C.gold)
            VStack(spacing: 4) {
                Eyebrow(text: "The #1 Prayer Habit App")
                StarRow(size: 13)
            }
            Image(systemName: "laurel.trailing").foregroundColor(PL.C.gold)
        }
        .font(.system(size: 34))
    }

    private var dots: some View {
        HStack(spacing: PL.S.md) {
            ForEach(0..<dotCount, id: \.self) { i in
                ZStack {
                    Circle()
                        .strokeBorder(i < filledDots ? PL.C.gold : PL.C.track, lineWidth: 1.5)
                        .background(Circle().fill(i < filledDots ? PL.C.gold : Color.clear))
                        .frame(width: 26, height: 26)
                    if i < filledDots {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Companion (the ring the user names — same widget shown on Home)

struct CompanionIntroScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                CompanionRing(level: 1, progress: 0).scaleEffect(1.3)
                    .padding(.bottom, PL.S.md)
                GoldHeadline("Meet your companion.", accents: ["companion"], size: 28, alignment: .center)
                PLSubtitle("As you pray each day, your faith grows. Your companion walks the journey with you.",
                           alignment: .center)
            }
        }
    }
}

struct CompanionNameScreen: View {
    @ObservedObject var ob: Onboarding
    @FocusState private var focused: Bool
    private var valid: Bool { !ob.companionName.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Let's go", enabled: valid, action: { focused = false; ob.next() })
        ) {
            VStack(spacing: PL.S.xl) {
                CompanionRing(level: 1, progress: 0).scaleEffect(1.2)
                    .padding(.bottom, PL.S.sm)
                GoldHeadline("Name your companion.", accents: ["companion"], size: 28, alignment: .center)
                PLSubtitle("A gentle reminder to return each day.", alignment: .center)
                PLTextField(placeholder: "Grace", text: $ob.companionName).focused($focused)
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { focused = true } }
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
                    GoldHeadline("Don't walk with God alone.", accents: ["God"], size: 27)
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
    @State private var requesting = false
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", enabled: !requesting, loading: requesting, action: {
                // Ask for Screen Time permission in context, then continue.
                // Loading state blocks repeat taps while the system prompt loads.
                guard !requesting else { return }
                requesting = true
                Task {
                    await ScreenTimeManager.shared.requestAuthorization()
                    requesting = false
                    ob.next()
                }
            })
        ) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                VStack(alignment: .leading, spacing: PL.S.md) {
                    GoldHeadline("Set your prayer times.", accents: ["prayer times"], size: 27)
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
    private let columns = 9
    private let totalDays = 90
    private let daysDone = 1   // day 1 (today) starts filled

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Start this plan", action: ob.next)
        ) {
            VStack(spacing: PL.S.xxl) {
                GoldHeadline("90 days to build consistency.", accents: ["consistency"],
                             size: 28, alignment: .center)
                heatmapCard
            }
            .padding(.top, PL.S.md)
        }
    }

    private var heatmapCard: some View {
        let grid = Array(repeating: GridItem(.flexible(), spacing: 7), count: columns)
        return VStack(alignment: .leading, spacing: PL.S.lg) {
            HStack {
                Text("90 day prayer journey")
                    .font(PL.F.sans(15, .semibold)).foregroundColor(PL.C.textOnInk)
                Spacer()
                Text("\(Int(Double(daysDone) / Double(totalDays) * 100))% complete")
                    .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.gold)
            }
            LazyVGrid(columns: grid, spacing: 7) {
                ForEach(0..<totalDays, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(i < daysDone ? PL.C.gold : Color.white.opacity(0.07))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            HStack {
                Text(Self.today)
                    .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textOnInkMuted)
                Spacer()
                Text(ob.firstName)
                    .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textOnInkMuted)
            }
            .padding(.top, PL.S.xs)
        }
        .padding(PL.S.xl)
        .background(PL.C.ink)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
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
            theme: .dark, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", style: .plainOnInk, enabled: hasSigned, action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                GoldHeadline("Make your commitment.", size: 27, base: PL.C.textOnInk)
                VStack(alignment: .leading, spacing: PL.S.md) {
                    commitmentRow("Seek God before my phone")
                    commitmentRow("Pray before scrolling")
                    commitmentRow("Be intentional with my screen time")
                    commitmentRow("Guard my heart and mind")
                }
                PLSubtitle("Sign as a reminder of the promise you're making.",
                           color: PL.C.textOnInkMuted)
                signaturePad
            }
        }
    }

    private func commitmentRow(_ t: String) -> some View {
        HStack(spacing: PL.S.md) {
            Image(systemName: "checkmark").font(.system(size: 15, weight: .bold))
                .foregroundColor(PL.C.gold)
            Text(t).font(PL.F.sans(16, .medium)).foregroundColor(PL.C.textOnInk)
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
