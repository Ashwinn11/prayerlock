import SwiftUI

/// Drives the onboarding flow: ordered steps, collected answers, navigation,
/// and the dynamic values that personalize later screens.
final class Onboarding: ObservableObject {

    enum Step: Hashable {
        // Intro
        case introSocialMedia, introHelps, introUnlock, name, honestStart
        // Questions (progress bar shown)
        case age, phoneHours, prayWeek, relationship, goals, thriving, inTheWay, realRoot, denomination, sex
        // Insights interleaved
        case insightYears, bible21, giveBack, social1, rightPlace
        // Personalizing + how it works
        case personalizing, howItWorks
        // First-prayer preview
        case feelingRelationship, feeling, guidedPrayer, prayOwn, verse, firstPrayerDone
        // Companion + community + setup
        case companionIntro, companionName, community, prayerTimes
        // Commitment + permission + proof + paywall
        case commitment, commitmentBeautiful, plan, signCommitment, notifications, social2, paywall
    }

    /// The full ordered flow.
    let order: [Step] = [
        .introSocialMedia, .introHelps, .introUnlock, .name, .honestStart,
        .age, .phoneHours, .insightYears, .bible21, .giveBack, .social1,
        .goals, .thriving, .rightPlace, .prayWeek, .relationship, .inTheWay,
        .realRoot, .denomination, .sex,
        .personalizing, .howItWorks,
        .feelingRelationship, .feeling, .guidedPrayer, .prayOwn, .verse, .firstPrayerDone,
        .companionIntro, .companionName, .community, .prayerTimes,
        .commitment, .commitmentBeautiful, .plan, .signCommitment,
        .notifications, .social2, .paywall,
    ]

    /// Steps that display the progress bar (the "question" segment).
    let questionSteps: [Step] = [
        .age, .phoneHours, .goals, .thriving, .prayWeek,
        .relationship, .inTheWay, .realRoot, .denomination, .sex,
    ]

    @Published var index: Int = 0
    @Published var forward: Bool = true
    var step: Step { order[index] }

    // MARK: Answers (all selections kept as sets for a uniform component API)
    @Published var name: String = ""
    @Published var age: Set<String> = []
    @Published var phoneHours: Int = 4
    @Published var prayWeek: Int = 4
    @Published var goals: Set<String> = []
    @Published var thriving: Set<String> = []
    @Published var relationship: Set<String> = []
    @Published var inTheWay: Set<String> = []
    @Published var realRoot: Set<String> = []
    @Published var denomination: Set<String> = []
    @Published var sex: Set<String> = []
    @Published var commitment: Set<String> = []
    @Published var companionName: String = ""
    @Published var feelingMood: Int = 2        // 0...4 emoji slider
    @Published var relationshipMood: Int = 2   // 0...4 emoji slider

    // MARK: Derived / dynamic
    var firstName: String {
        let t = name.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? "friend" : t
    }
    /// "7 years" from 4 hrs/day — fraction of day over a ~40-year horizon.
    var yearsOnPhone: Int {
        max(1, Int((Double(phoneHours) * 40.0 / 24.0).rounded()))
    }
    /// "Bible in 21 days" — the KJV takes ~84 hours to read; scale by daily screen time.
    var bibleDays: Int {
        max(3, Int((84.0 / Double(max(1, phoneHours))).rounded()))
    }
    /// Guided prayer chosen from the two emoji check-ins (the core selection logic,
    /// shared with the in-app "Pray today" flow).
    var selectedPrayer: GuidedPrayer {
        PrayerLibrary.forMoods(feeling: feelingMood, relationship: relationshipMood)
    }
    /// First selected goal, used on the reflect screen.
    var primaryGoal: String { goals.first ?? "Deepen my relationship with God" }
    var primaryThriving: String { thriving.first ?? "Building my life on the word of God" }
    var denominationValue: String { denomination.first ?? "" }
    var commitmentLevel: String { commitment.first ?? "" }

    /// "Your commitment is beautiful" screen — adapts to the level chosen.
    /// (The "beautiful" variant is the one verified from the screenshot; the others
    /// are authored in the same voice.)
    var commitmentAffirmation: (headline: String, accent: String, subtitle: String) {
        switch commitmentLevel {
        case "Extremely committed":
            return ("Your commitment is unshakable.", "unshakable",
                    "A heart this set on God will not be moved. And on the days it dips, it's His grace — not your willpower — that carries you forward.")
        case "Very committed", "":
            return ("Your commitment is beautiful.", "beautiful",
                    "Your commitment is a gift. And on the days it dips, it's God's grace — not your willpower — that carries you forward.")
        case "Somewhat committed":
            return ("Every honest step counts.", "Every honest step",
                    "You don't have to feel ready. Just show up, and let God meet you there — His grace will carry the rest.")
        case "A little committed":
            return ("Small beginnings, faithful God.", "faithful God",
                    "He is not waiting for your willpower. He's waiting for your yes — even a small one — and His grace does the carrying.")
        default: // Just trying it out
            return ("Curiosity is a holy start.", "holy start",
                    "Even \u{201C}just trying\u{201D} is God drawing you near. Come as you are — His grace, not your willpower, carries the journey.")
        }
    }

    /// Progress 0...1 across the question segment; nil for non-question steps.
    var progress: Double? {
        guard let pos = questionSteps.firstIndex(of: step) else { return nil }
        return Double(pos + 1) / Double(questionSteps.count)
    }

    var showBack: Bool { index > 0 }

    // MARK: Navigation
    func next() {
        if index < order.count - 1 {
            forward = true
            withAnimation(.easeInOut(duration: 0.28)) { index += 1 }
        } else {
            finish()
        }
    }
    func back() {
        guard index > 0 else { return }
        forward = false
        withAnimation(.easeInOut(duration: 0.28)) { index -= 1 }
    }

    /// Persist results and flip the app into the main experience.
    func finish() {
        let m = AppModel.shared
        m.userName = firstName
        m.companionName = companionName.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Grace" : companionName
        m.denomination = denominationValue
        m.planStartEpoch = Date().timeIntervalSince1970
        // The onboarding prayer is mandatory — record it so the journal entry,
        // streak, and heatmaps reflect day 1 from the start.
        if m.totalPrayers == 0 {
            m.completePrayer(entry: PrayerLibrary.entry(for: selectedPrayer))
        }
        m.onboardingComplete = true
    }
}
