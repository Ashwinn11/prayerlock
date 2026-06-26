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

/// Prayer Lock palette — warm cream + charcoal-brown + gold accent.
/// Extends the shared `PL` namespace (defined in Shared/PrayerLockShared.swift).
extension PL {
    enum C {
        /// Light "question" screen background.
        static let cream = Color(hex: 0xF1ECE3)
        /// Slightly lighter card / field surface on cream.
        static let card = Color(hex: 0xFAF7F0)
        /// Dark "insight" screen background.
        static let ink = Color(hex: 0x36322B)
        /// Card surface used on dark screens.
        static let inkCard = Color(hex: 0x423D34)

        /// Primary text (near-black warm brown).
        static let text = Color(hex: 0x2E2A24)
        /// Secondary / muted text.
        static let textMuted = Color(hex: 0x8C857A)
        /// Text on dark backgrounds.
        static let textOnInk = Color(hex: 0xF3EEE6)
        static let textOnInkMuted = Color(hex: 0xB7AE9F)

        /// Gold / amber accent (emphasis words, slider fill, progress).
        static let gold = Color(hex: 0xB5832E)

        /// Primary pill button fill + its text.
        static let button = Color(hex: 0x36322B)
        static let buttonText = Color(hex: 0xF6F1E8)
        static let buttonDisabled = Color(hex: 0xA9A399)

        /// Hairline / track colors.
        static let track = Color(hex: 0xDED7CA)
        static let stroke = Color(hex: 0xE4DDD0)
    }
}
