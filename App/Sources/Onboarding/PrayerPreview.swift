import SwiftUI

/// Guided prayer reading (onboarding first-prayer preview).
struct GuidedPrayerReadingScreen: View {
    @ObservedObject var ob: Onboarding
    var title: String = "Let's pray"
    var prayer: GuidedPrayer = PrayerLibrary.byID("be-still")

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: PL.S.xl) {
                    Eyebrow(text: "A Moment of Prayer")
                    GoldHeadline(title, size: 32, alignment: .center)
                    Text(prayer.body)
                        .font(.plBody).foregroundColor(PL.C.text)
                        .multilineTextAlignment(.center).lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    ScriptureBlock(text: prayer.scripture, reference: prayer.reference)
                        .padding(.top, PL.S.sm)
                }
                .padding(.vertical, PL.S.xl)
            }
        }
    }
}

/// Verse of the day (onboarding).
struct VerseScreen: View {
    @ObservedObject var ob: Onboarding
    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xxl) {
                Eyebrow(text: "Verse of the Day")
                ScriptureBlock(text: PrayerLibrary.verseOfDay.text,
                               reference: PrayerLibrary.verseOfDay.reference, size: 23)
            }
        }
    }
}

/// "You completed your first prayer." with a saved-entry preview.
struct FirstPrayerDoneScreen: View {
    @ObservedObject var ob: Onboarding
    private var prayer: GuidedPrayer { PrayerLibrary.byID("be-still") }

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xl) {
                GoldHeadline("You completed your first prayer.", accents: ["first prayer"],
                             size: 29, alignment: .center)
                JournalEntryCard(
                    entry: JournalEntry(title: prayer.title, prayerText: prayer.body,
                                        scriptureText: prayer.scripture,
                                        scriptureRef: prayer.reference),
                    showChevron: false)
                PLSubtitle("Your prayers are saved to your journal to help you build a stronger relationship with God.",
                           alignment: .center)
            }
        }
    }
}
