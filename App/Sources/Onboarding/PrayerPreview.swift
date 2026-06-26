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
                GoldHeadline("Let's pray", size: 28, alignment: .center)
                TypewriterText(text: prayer.body, font: .plBody, color: PL.C.textMuted)
                ScriptureDarkCard(text: prayer.scripture, reference: prayer.reference,
                                  italic: true, textColor: PL.C.gold, refColor: PL.C.textOnInk)
                    .padding(.top, PL.S.sm)
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
                IllustrationSlot(name: "cross-thorns", fallbackSymbol: "cross.fill", size: 110)
                Eyebrow(text: "Verse of the Day")
                ScriptureDarkCard(text: PrayerLibrary.verseOfDay.text,
                                  reference: PrayerLibrary.verseOfDay.reference)
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
                IllustrationSlot(name: "hand-cross", fallbackSymbol: "hands.sparkles.fill", size: 120)
                GoldHeadline("You completed your first prayer.", accents: ["first prayer"],
                             size: 27, alignment: .center)
                JournalEntryCard(
                    entry: JournalEntry(title: prayer.title, prayerText: prayer.body,
                                        scriptureText: prayer.scripture,
                                        scriptureRef: prayer.reference),
                    dark: true)
                PLSubtitle("Your prayers are saved to your journal to help you build a stronger relationship with God.",
                           alignment: .center)
            }
        }
    }
}
