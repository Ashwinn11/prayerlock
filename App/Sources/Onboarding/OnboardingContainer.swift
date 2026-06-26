import SwiftUI

struct OnboardingContainer: View {
    @StateObject private var ob = Onboarding()

    var body: some View {
        ZStack {
            screen
                .id(ob.index)
                .transition(.asymmetric(
                    insertion: .move(edge: ob.forward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: ob.forward ? .leading : .trailing).combined(with: .opacity)
                ))
        }
    }

    @ViewBuilder private var screen: some View {
        switch ob.step {

        // MARK: Intro
        case .introSocialMedia:
            InsightScreen(ob: ob, illustration: "praying-woman", symbol: "figure.mind.and.body",
                          headline: "Social media is taking you away from God.", accents: ["God"])
        case .introHelps:
            InsightScreen(ob: ob, illustration: "church", symbol: "building.columns.fill",
                          headline: "PrayerLock helps you choose God first, daily.",
                          accents: ["PrayerLock"])
        case .introUnlock:
            InsightScreen(ob: ob, illustration: "cross-shroud", symbol: "cross.fill",
                          headline: "Once you pray, your apps unlock.", accents: ["pray"],
                          buttonTitle: "Get started")
        case .name:
            TextInputScreen(ob: ob, illustration: "dove", symbol: "bird.fill",
                            title: "What should we call you?",
                            subtitle: "We'll personalize your journey.",
                            placeholder: "Your name", text: $ob.name)
        case .honestStart:
            InsightScreen(ob: ob, illustration: "rosary", symbol: "hands.sparkles.fill",
                          headline: "\(ob.firstName), answer these honestly.",
                          subtitle: "They help us understand where you are in your walk with God, and personalize your journey closer to Jesus.",
                          buttonTitle: "Let's start")

        // MARK: Questions
        case .age:
            QuestionScreen(ob: ob, title: "How old are you?",
                           options: ["14-24", "25-34", "35-44", "45-54", "55+"],
                           selection: $ob.age)
        case .phoneHours:
            SliderScreen(ob: ob, title: "How long are you on your phone each day?",
                         unit: "hours/day", range: 1...10, value: $ob.phoneHours)
        case .prayWeek:
            SliderScreen(ob: ob, title: "How often do you pray per week?",
                         unit: "days/week", range: 0...7, value: $ob.prayWeek)
        case .goals:
            QuestionScreen(ob: ob, title: "What do you want to achieve with PrayerLock?",
                           accents: ["achieve"], subtitle: "Choose up to 3.",
                           options: ["Put God first, before my phone",
                                     "Build a consistent prayer habit",
                                     "Deepen my relationship with God",
                                     "Find peace in a chaotic world",
                                     "Start my day with intention"],
                           selection: $ob.goals, mode: .multi(max: 3))
        case .thriving:
            QuestionScreen(ob: ob, title: "What does a thriving faith look like to you?",
                           accents: ["thriving faith"],
                           options: ["Trusting God's plan, even when it's hard",
                                     "Living out my faith with integrity",
                                     "Using my gifts to serve others",
                                     "Building my life on the word of God"],
                           selection: $ob.thriving)
        case .relationship:
            QuestionScreen(ob: ob, title: "How would you describe your relationship with God right now?",
                           accents: ["relationship with God"],
                           options: ["It has its ups and downs",
                                     "Feeling a bit distant lately",
                                     "Just starting or rebuilding",
                                     "Close and consistent"],
                           selection: $ob.relationship)
        case .inTheWay:
            QuestionScreen(ob: ob, title: "What gets in the way of that thriving faith?",
                           accents: ["thriving faith"], subtitle: "Choose up to 3.",
                           options: ["Phone & social media distraction",
                                     "Lack of focus or wandering thoughts",
                                     "Lack of motivation, feeling dry",
                                     "Busyness and lack of time",
                                     "Not knowing what to say"],
                           selection: $ob.inTheWay, mode: .multi(max: 3))
        case .realRoot:
            QuestionScreen(ob: ob, title: "Sometimes the real root runs deeper. Any of these?",
                           accents: ["real root"], subtitle: "Choose any that apply.",
                           options: ["Struggling with lustful thoughts",
                                     "Constant worry or anxiety",
                                     "Loneliness or emptiness",
                                     "Pride or self-reliance",
                                     "None of these"],
                           selection: $ob.realRoot, mode: .multi(max: nil))
        case .denomination:
            QuestionScreen(ob: ob, title: "What is your Christian denomination?",
                           accents: ["denomination"],
                           subtitle: "So the prayers and scriptures feel right for you.",
                           options: ["Non-denominational", "Protestant", "Catholic",
                                     "Orthodox", "None of the above"],
                           selection: $ob.denomination)
        case .sex:
            QuestionScreen(ob: ob, title: "What's your sex?", accents: ["sex"],
                           subtitle: "So the prayers and scriptures feel right for you.",
                           options: ["Man", "Woman", "Prefer not to say"],
                           selection: $ob.sex)

        // MARK: Insights
        case .insightYears:
            InsightScreen(ob: ob, theme: .dark, emoji: "😵‍💫",
                          headline: "\(ob.firstName), at this rate you'll spend \(ob.yearsOnPhone) years of your life on your phone.",
                          accents: ["\(ob.yearsOnPhone) years"],
                          buttonStyle: .plainOnInk)
        case .bible21:
            InsightScreen(ob: ob, illustration: "bible", symbol: "book.closed.fill",
                          headline: "You could read the entire Bible in 21 days.",
                          accents: ["entire Bible"],
                          subtitle: "If you traded screen time for scripture time.")
        case .giveBack:
            InsightScreen(ob: ob, theme: .dark, illustration: "hands-cross", symbol: "hands.sparkles.fill",
                          headline: "The good news: we'll help you give \(ob.yearsOnPhone) years back to God.",
                          accents: ["\(ob.yearsOnPhone) years back to God"],
                          buttonStyle: .plainOnInk)
        case .social1:
            SocialProofScreen(ob: ob,
                              headline: "200,000+ Christians are choosing God over their screens.",
                              accents: ["God"])
        case .rightPlace:
            RightPlaceScreen(ob: ob)

        // MARK: Personalizing + how it works
        case .personalizing:
            PersonalizingScreen(ob: ob)
        case .howItWorks:
            HowItWorksScreen(ob: ob)

        // MARK: First-prayer preview
        case .feelingRelationship:
            TextInputScreen(ob: ob, showIllustration: false,
                            title: "How's your relationship with God today?",
                            accents: ["relationship with God"],
                            placeholder: "Share a word or two…", text: $ob.relationshipToday)
        case .feeling:
            TextInputScreen(ob: ob, showIllustration: false,
                            title: "How are you feeling today?", accents: ["feeling"],
                            placeholder: "Share how you're feeling…", text: $ob.feeling)
        case .guidedPrayer:
            GuidedPrayerReadingScreen(ob: ob, prayer: PrayerLibrary.forMood(ob.feeling))
        case .prayOwn:
            InsightScreen(ob: ob, illustration: "praying-hands", symbol: "hands.sparkles",
                          headline: "You can also pray on your own.",
                          accents: ["pray on your own"],
                          subtitle: "Next time your apps lock, choose a guided prayer or just talk to God in your own words.")
        case .verse:
            VerseScreen(ob: ob)
        case .firstPrayerDone:
            FirstPrayerDoneScreen(ob: ob)

        // MARK: Companion + community + setup
        case .companionIntro:
            InsightScreen(ob: ob, illustration: "companion", symbol: "leaf.fill",
                          headline: "Meet your companion.", accents: ["companion"],
                          subtitle: "As you pray each day, your faith grows. Your companion walks the journey with you.")
        case .companionName:
            TextInputScreen(ob: ob, illustration: "companion", symbol: "leaf.fill",
                            title: "Name your companion.",
                            subtitle: "A gentle reminder to return each day.",
                            placeholder: "Grace", text: $ob.companionName, buttonTitle: "Let's go")
        case .community:
            CommunityScreen(ob: ob)
        case .prayerTimes:
            PrayerTimesSetupScreen(ob: ob)

        // MARK: Commitment + permission + proof + paywall
        case .commitment:
            QuestionScreen(ob: ob, title: "How committed are you to making this happen?",
                           accents: ["committed"],
                           options: ["Extremely committed", "Very committed",
                                     "Somewhat committed", "A little committed",
                                     "Just trying it out"],
                           selection: $ob.commitment)
        case .commitmentBeautiful:
            InsightScreen(ob: ob, theme: .dark, illustration: "dove", symbol: "heart.fill",
                          headline: "Your commitment is beautiful.", accents: ["beautiful"],
                          subtitle: "Your commitment is a gift. And on the days it dips, it's God's grace — not your willpower — that carries you forward.",
                          buttonTitle: "Done", buttonStyle: .plainOnInk)
        case .plan:
            PlanScreen(ob: ob)
        case .signCommitment:
            SignCommitmentScreen(ob: ob)
        case .notifications:
            NotificationsScreen(ob: ob)
        case .social2:
            SocialProofScreen(ob: ob, headline: "Designed for christians like you.",
                              accents: ["christians"], buttonTitle: "Join PrayerLock")
        case .paywall:
            PaywallScreen(ob: ob)
        }
    }
}
