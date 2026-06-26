import SwiftUI

/// Type system: Newsreader (warm editorial serif) for headlines & numerals,
/// Newsreader italic for scripture, Hanken Grotesk for body & UI.
extension PL {
    enum F {
        // MARK: Serif (Newsreader) — headlines & numerals
        static func serif(_ size: CGFloat, _ weight: SerifWeight = .regular) -> Font {
            .custom(weight.psName, size: size)
        }
        // MARK: Serif italic (Newsreader) — used for scripture quotes
        static func serifItalic(_ size: CGFloat, medium: Bool = false) -> Font {
            .custom(medium ? "Newsreader-MediumItalic" : "Newsreader-Italic", size: size)
        }
        // MARK: Sans (Hanken Grotesk) — body & UI
        static func sans(_ size: CGFloat, _ weight: SansWeight = .regular) -> Font {
            .custom(weight.psName, size: size)
        }

        enum SerifWeight {
            case light, regular, medium, semibold, bold
            var psName: String {
                switch self {
                case .light: return "Newsreader-Light"
                case .regular: return "Newsreader-Regular"
                case .medium: return "Newsreader-Medium"
                case .semibold: return "Newsreader-SemiBold"
                case .bold: return "Newsreader-Bold"
                }
            }
        }
        enum SansWeight {
            case regular, medium, semibold, bold, extrabold
            var psName: String {
                switch self {
                case .regular: return "HankenGrotesk-Regular"
                case .medium: return "HankenGrotesk-Medium"
                case .semibold: return "HankenGrotesk-SemiBold"
                case .bold: return "HankenGrotesk-Bold"
                case .extrabold: return "HankenGrotesk-ExtraBold"
                }
            }
        }
    }
}

// MARK: - Semantic text styles

extension Font {
    /// Large screen title (serif). ~34pt.
    static var plTitle: Font { PL.F.serif(34, .regular) }
    /// Big hero/insight headline (serif). ~30pt.
    static var plHeadline: Font { PL.F.serif(30, .regular) }
    /// Section header on main screens (serif). ~26pt.
    static var plSectionTitle: Font { PL.F.serif(26, .medium) }
    /// Body copy (sans).
    static var plBody: Font { PL.F.sans(16, .regular) }
    /// Subtitle / supporting copy (sans).
    static var plSubtitle: Font { PL.F.sans(15, .medium) }
    /// Option row label (sans).
    static var plOption: Font { PL.F.sans(16, .medium) }
    /// Button label (sans).
    static var plButton: Font { PL.F.sans(17, .semibold) }
    /// Small tracked-out caps label (sans).
    static var plEyebrow: Font { PL.F.sans(13, .bold) }
}

// MARK: - Helpers

extension Text {
    /// Tracked-out uppercase eyebrow label (e.g. "VERSE OF THE DAY").
    func plEyebrowStyle(_ color: Color = PL.C.gold) -> some View {
        self.font(.plEyebrow)
            .tracking(1.6)
            .foregroundStyle(color)
    }
}
