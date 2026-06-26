import SwiftUI

/// Tracked-out caps label (e.g. "VERSE OF THE DAY", scripture refs).
struct Eyebrow: View {
    let text: String
    var color: Color = PL.C.gold
    var body: some View {
        Text(text.uppercased()).plEyebrowStyle(color)
    }
}

/// Italic scripture quote + reference, centered.
struct ScriptureBlock: View {
    let text: String
    let reference: String
    var theme: ScreenTheme = .light
    var size: CGFloat = 19
    var body: some View {
        VStack(spacing: PL.S.lg) {
            Text("\u{201C}\(text)\u{201D}")
                .font(PL.F.serifItalic(size))
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
            Eyebrow(text: reference)
        }
    }
}

/// Slot for an illustration asset. Renders the named asset when present (your SVGs),
/// otherwise a tasteful on-brand placeholder so layout is faithful before art lands.
struct IllustrationSlot: View {
    let name: String
    var fallbackSymbol: String = "cross.fill"
    var size: CGFloat = 180

    private var assetExists: Bool { UIImage(named: name) != nil }

    var body: some View {
        Group {
            if assetExists {
                Image(name).resizable().scaledToFit()
            } else {
                ZStack {
                    Circle().fill(PL.C.gold.opacity(0.18))
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: size * 0.34, weight: .light))
                        .foregroundColor(PL.C.gold)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// Centered illustration + headline (+ subtitle). Used by intro / info screens.
struct HeroBlock: View {
    let illustration: String
    var symbol: String = "cross.fill"
    let headline: String
    var accents: [String] = []
    var subtitle: String? = nil
    var theme: ScreenTheme = .light
    var illustrationSize: CGFloat = 180

    var body: some View {
        VStack(spacing: PL.S.xl) {
            IllustrationSlot(name: illustration, fallbackSymbol: symbol, size: illustrationSize)
            GoldHeadline(text: headline, accents: accents, size: 28,
                         base: theme.textPrimary, alignment: .center)
            if let subtitle {
                PLSubtitle(subtitle, alignment: .center, color: theme.textMuted)
            }
        }
    }
}

/// Left-aligned title (+ subtitle) used at the top of question screens.
struct QuestionHeader: View {
    let title: String
    var accents: [String] = []
    var subtitle: String? = nil
    var theme: ScreenTheme = .light

    var body: some View {
        VStack(alignment: .leading, spacing: PL.S.md) {
            GoldHeadline(text: title, accents: accents, size: 27,
                         base: theme.textPrimary, alignment: .leading)
            if let subtitle {
                PLSubtitle(subtitle, color: theme.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
