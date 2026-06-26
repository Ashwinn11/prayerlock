import SwiftUI

/// Layout tokens. Derived from the 390pt-wide reference screens.
extension PL {
    /// Spacing scale (4-pt base).
    enum S {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    /// Corner radii.
    enum R {
        static let field: CGFloat = 16
        static let card: CGFloat = 18
        static let bigCard: CGFloat = 24
        static let pill: CGFloat = 999
    }

    /// Fixed layout metrics.
    enum L {
        /// Screen horizontal margin (option rows sit at ~24pt).
        static let margin: CGFloat = 24
        /// Primary pill button height.
        static let buttonHeight: CGFloat = 64
        /// Circular back button diameter.
        static let backButton: CGFloat = 44
        /// Option row min height.
        static let optionRow: CGFloat = 64
        /// Progress bar height.
        static let progressBar: CGFloat = 6
        /// Standard bottom inset above the home indicator for the button.
        static let bottomBar: CGFloat = 8
    }
}

/// Reusable hairline border for cream surfaces.
extension View {
    func plCardStroke(_ radius: CGFloat = PL.R.card) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(PL.C.stroke, lineWidth: 1)
        )
    }
}
