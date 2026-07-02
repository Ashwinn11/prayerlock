import SwiftUI

// MARK: - Reusable: single/multi choice question

struct QuestionScreen: View {
    @ObservedObject var ob: Onboarding
    let title: String
    var accents: [String] = []
    var subtitle: String? = nil
    let options: [String]
    @Binding var selection: Set<String>
    var mode: SelectMode = .single

    private var valid: Bool {
        switch mode {
        case .single: return selection.count == 1
        case .multi: return !selection.isEmpty
        }
    }

    var body: some View {
        OnbScaffold(
            theme: .light,
            showBack: ob.showBack,
            progress: ob.progress,
            onBack: ob.back,
            primary: ButtonConfig(title: "Continue", enabled: valid, action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                QuestionHeader(title: title, accents: accents, subtitle: subtitle)
                    .plReveal(0)
                SelectableList(options: options, selection: $selection, mode: mode)
            }
        }
    }
}

// MARK: - Reusable: numeric slider question

struct SliderScreen: View {
    @ObservedObject var ob: Onboarding
    let title: String
    var subtitle: String? = "Be honest."
    let unit: String
    let range: ClosedRange<Int>
    @Binding var value: Int
    /// Optional live line under the slider derived from the value (e.g. "≈ 7 years of your life").
    var note: ((Int) -> String)? = nil

    var body: some View {
        OnbScaffold(
            theme: .light,
            showBack: ob.showBack,
            progress: ob.progress,
            onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(alignment: .leading, spacing: 0) {
                QuestionHeader(title: title, subtitle: subtitle)
                    .plReveal(0)
                Spacer().frame(height: PL.S.xxxl)
                ValueSlider(value: $value, range: range, unit: unit)
                    .padding(.horizontal, PL.S.xs)
                    .plReveal(1)
                if let note {
                    Text(note(value))
                        .font(PL.F.sans(14, .semibold))
                        .foregroundColor(PL.C.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.top, PL.S.xl)
                        .contentTransition(.numericText())
                        .animation(PL.Motion.snappy, value: value)
                        .plReveal(2)
                }
            }
        }
    }
}

// MARK: - Reusable: emoji mood check-in (relationship / feeling)

struct MoodSliderScreen: View {
    @ObservedObject var ob: Onboarding
    let title: String
    var accents: [String] = []
    let stops: [MoodStop]
    @Binding var index: Int

    var body: some View {
        OnbScaffold(
            theme: .light, showBack: ob.showBack, progress: nil, centered: true,
            onBack: ob.back,
            primary: ButtonConfig(title: "Continue", action: ob.next)
        ) {
            VStack(spacing: PL.S.xxxl) {
                GoldHeadline(title, accents: accents, size: 28, alignment: .center, foil: true)
                    .plReveal(0)
                EmojiSlider(stops: stops, index: $index)
                    .plReveal(1)
            }
        }
    }
}

// MARK: - Reusable: insight / intro / info screen

struct InsightScreen: View {
    @ObservedObject var ob: Onboarding
    var theme: ScreenTheme = .light
    var illustration: String = ""
    var symbol: String = "cross.fill"
    var emoji: String? = nil
    let headline: String
    var accents: [String] = []
    var subtitle: String? = nil
    var buttonTitle: String = "Continue"
    var buttonStyle: PrimaryButton.Style = .primary
    var illustrationSize: CGFloat = 168

    var body: some View {
        OnbScaffold(
            theme: theme,
            showBack: ob.showBack,
            progress: nil,
            centered: true,
            onBack: ob.back,
            primary: ButtonConfig(title: buttonTitle, style: buttonStyle, action: ob.next),
            godRays: theme == .dark
        ) {
            VStack(spacing: PL.S.xl) {
                Group {
                    if let emoji {
                        Text(emoji).font(.system(size: 76))
                            .scaleEffect(1).shadow(color: PL.C.goldGlow.opacity(theme == .dark ? 0.5 : 0), radius: 24)
                    } else {
                        FloatingIllustration(name: illustration, symbol: symbol,
                                             size: illustrationSize, glow: theme == .dark)
                    }
                }
                .plReveal(0)
                GoldHeadline(headline, accents: accents, size: 28,
                             base: theme.textPrimary, alignment: .center, foil: true)
                    .plReveal(1)
                if let subtitle {
                    PLSubtitle(subtitle, alignment: .center, color: theme.textMuted)
                        .plReveal(2)
                }
            }
        }
    }
}

// Convenience initializer so GoldHeadline can be created positionally above.
extension GoldHeadline {
    init(_ text: String, accents: [String] = [], size: CGFloat = 32,
         weight: PL.F.SerifWeight = .regular, base: Color = PL.C.text,
         accent: Color = PL.C.gold, alignment: TextAlignment = .leading,
         foil: Bool = false) {
        self.init(text: text, accents: accents, size: size, weight: weight,
                  base: base, accent: accent, alignment: alignment, foil: foil)
    }
}
