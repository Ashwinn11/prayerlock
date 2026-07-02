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
        /// Gold spectrum for foil, gradients, glow. `goldHi` = specular highlight,
        /// `goldDeep` = amber shadow. Used by the goldFoil shader + gilded surfaces.
        static let goldHi = Color(hex: 0xE7BE71)
        static let goldLight = Color(hex: 0xC79A50)
        static let goldDeep = Color(hex: 0x6E4A22)
        /// Warm glow tint radiated by light-emitting surfaces (buttons, rings, unlock).
        static let goldGlow = Color(hex: 0xD9A24A)

        /// Cream depth stops — feed the light-screen ambient mesh + vignette.
        static let creamHi = Color(hex: 0xFDFBF6)
        static let creamDeep = Color(hex: 0xE7DECE)
        /// Warm ink depth stops — feed the dark-screen ambient mesh + raised surfaces.
        static let inkRaised = Color(hex: 0x413B33)
        static let inkGlow = Color(hex: 0x4E4539)

        /// Warm-tinted shadows (never pure black) — two-layer elevation.
        static let shadowAmbient = Color(.sRGB, red: 0.22, green: 0.16, blue: 0.07, opacity: 0.10)
        static let shadowKey = Color(.sRGB, red: 0.20, green: 0.14, blue: 0.05, opacity: 0.16)
        /// Warm translucent film for hand-built glass surfaces.
        static let glassTint = Color(.sRGB, red: 1, green: 0.99, blue: 0.96, opacity: 0.55)
        static let glassTintDark = Color(.sRGB, red: 0.28, green: 0.25, blue: 0.20, opacity: 0.45)

        /// Primary pill button fill + its text.
        static let button = Color(hex: 0x34302A)
        static let buttonText = Color(hex: 0xFBF8F1)
        static let buttonDisabled = Color(hex: 0x9C9486)

        /// Hairline / track / border colors.
        static let track = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.07)
        static let stroke = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.14)
    }
}
