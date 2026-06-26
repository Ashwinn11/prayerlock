import SwiftUI

/// Type system: Fraunces (display serif, 144pt optical cut) for headlines & numerals,
/// Fraunces 72pt italic for scripture, Manrope for body & UI.
extension PL {
    enum F {
        // MARK: Serif display (Fraunces 144pt optical size)
        static func serif(_ size: CGFloat, _ weight: SerifWeight = .regular) -> Font {
            .custom(weight.psName, size: size)
        }
        // MARK: Serif italic (Fraunces 72pt) — used for scripture quotes
        static func serifItalic(_ size: CGFloat, medium: Bool = false) -> Font {
            .custom(medium ? "Fraunces72pt-MediumItalic" : "Fraunces72pt-Italic", size: size)
        }
        // MARK: Sans (Manrope) — body & UI
        static func sans(_ size: CGFloat, _ weight: SansWeight = .regular) -> Font {
            .custom(weight.psName, size: size)
        }

        enum SerifWeight {
            case light, regular, medium, semibold, bold
            var psName: String {
                switch self {
                case .light: return "Fraunces144pt-Light"
                case .regular: return "Fraunces144pt-Regular"
                case .medium: return "Fraunces144pt-Medium"
                case .semibold: return "Fraunces144pt-SemiBold"
                case .bold: return "Fraunces144pt-Bold"
                }
            }
        }
        enum SansWeight {
            case regular, medium, semibold, bold, extrabold
            var psName: String {
                switch self {
                case .regular: return "Manrope-Regular"
                case .medium: return "Manrope-Medium"
                case .semibold: return "Manrope-SemiBold"
                case .bold: return "Manrope-Bold"
                case .extrabold: return "Manrope-ExtraBold"
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
    static var plBody: Font { PL.F.sans(17, .regular) }
    /// Subtitle / supporting copy (sans).
    static var plSubtitle: Font { PL.F.sans(16, .medium) }
    /// Option row label (sans).
    static var plOption: Font { PL.F.sans(17, .medium) }
    /// Button label (sans).
    static var plButton: Font { PL.F.sans(18, .semibold) }
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
