import SwiftUI

/// Guided prayer reading (onboarding first-prayer preview) — prayer types out,
/// scripture sits in a dark card. Uses the prayer chosen from the emoji check-ins.
struct GuidedPrayerReadingScreen: View {
    @ObservedObject var ob: Onboarding
    private var prayer: GuidedPrayer { ob.selectedPrayer }

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                Eyebrow(text: "A Moment of Prayer")
                    .plReveal(0)
                GoldHeadline("Let's pray", size: 28, alignment: .center)
                    .plReveal(1)
                TypewriterText(text: prayer.body, font: .plBody, color: PL.C.textMuted)
                ScriptureDarkCard(text: prayer.scripture, reference: prayer.reference,
                                  italic: true, textColor: PL.C.gold, refColor: PL.C.textOnInk)
                    .padding(.top, PL.S.sm)
                    .plReveal(2)
            }
        }
    }
}

/// Verse of the day (onboarding) — cross-and-thorns illustration + verse in a dark card.
struct VerseScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                FloatingIllustration(name: "cross-thorns", symbol: "cross.fill", size: 110)
                    .plReveal(0)
                Eyebrow(text: "Verse of the Day")
                    .plReveal(1)
                ScriptureDarkCard(text: PrayerLibrary.verseOfDay.text,
                                  reference: PrayerLibrary.verseOfDay.reference)
                    .plReveal(2)
            }
        }
    }
}

/// "You completed your first prayer." — hand-cross illustration + saved entry in a dark card.
struct FirstPrayerDoneScreen: View {
    @ObservedObject var ob: Onboarding
    private var prayer: GuidedPrayer { ob.selectedPrayer }

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                FloatingIllustration(name: "hand-cross", symbol: "hands.sparkles.fill", size: 120)
                    .plReveal(0)
                GoldHeadline("You completed your first prayer.", accents: ["first prayer"],
                             size: 27, alignment: .center, foil: true)
                    .plReveal(1)
                JournalEntryCard(
                    entry: JournalEntry(title: prayer.title, prayerText: prayer.body,
                                        scriptureText: prayer.scripture,
                                        scriptureRef: prayer.reference),
                    dark: true)
                    .plReveal(2)
                PLSubtitle("Your prayers are saved to your journal to help you build a stronger relationship with God.",
                           alignment: .center)
                    .plReveal(3)
            }
        }
        .onAppear { PL.Haptics.success() }   // the first "you did it" moment
    }
}
