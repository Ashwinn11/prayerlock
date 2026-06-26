import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

/// Prayer Lock palette — bone paper + warm ink + single gold accent.
/// Synced with the canonical Quiet Sanctuary design tokens (PrayerLock/Theme.swift).
extension PL {
    enum C {
        /// Primary screen background — bone paper.
        static let cream = Color(hex: 0xF4EFE6)
        /// Cards, list groups, field surfaces.
        static let card = Color(hex: 0xFBF8F1)
        /// Dark insight/interstitial screen background.
        static let ink = Color(hex: 0x34302A)
        /// Alt background — shield / lock / illustration plate.
        static let inkCard = Color(hex: 0xEFE9DD)

        /// Primary text (near-black warm brown).
        static let text = Color(hex: 0x34302A)
        /// Secondary / muted text.
        static let textMuted = Color(hex: 0x6F6A61)
        /// Text on dark backgrounds.
        static let textOnInk = Color(hex: 0xF4EFE6)
        /// Muted text on dark backgrounds.
        static let textOnInkMuted = Color(hex: 0x9C9486)

        /// The single gold accent — emphasis words, slider fill, progress.
        static let gold = Color(hex: 0xA87C3D)

        /// Primary pill button fill + its text.
        static let button = Color(hex: 0x34302A)
        static let buttonText = Color(hex: 0xFBF8F1)
        static let buttonDisabled = Color(hex: 0x9C9486)

        /// Hairline / track / border colors.
        static let track = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.07)
        static let stroke = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.14)
    }
}
