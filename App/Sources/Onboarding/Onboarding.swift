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
    @Published var feeling: String = ""
    @Published var relationshipToday: String = ""

    // MARK: Derived / dynamic
    var firstName: String {
        let t = name.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? "friend" : t
    }
    /// "7 years" from 4 hrs/day — fraction of day over a ~40-year horizon.
    var yearsOnPhone: Int {
        max(1, Int((Double(phoneHours) * 40.0 / 24.0).rounded()))
    }
    /// First selected goal, used on the reflect screen.
    var primaryGoal: String { goals.first ?? "Deepen my relationship with God" }
    var primaryThriving: String { thriving.first ?? "Building my life on the word of God" }
    var denominationValue: String { denomination.first ?? "" }

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
        m.onboardingComplete = true
    }
}
