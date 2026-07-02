import SwiftUI

/// Hand-built "liquid glass": frosted material + warm tint + a specular top edge +
/// a hairline that catches light at the top and grounds at the bottom + two-layer warm
/// shadow. Looks premium on iOS 18; the tab bar/buttons additionally light up the real
/// iOS-26 `.glassEffect` where available. Works over any `Shape`.
extension PL {
    enum Glass {
        enum Elevation {
            case card, floating, button, hero
            var ambient: (r: CGFloat, y: CGFloat) {
                switch self {
                case .card:     return (16, 8)
                case .floating: return (26, 14)
                case .button:   return (10, 5)
                case .hero:     return (34, 20)
                }
            }
            var key: (r: CGFloat, y: CGFloat) {
                switch self {
                case .card:     return (4, 2)
                case .floating: return (6, 3)
                case .button:   return (3, 1.5)
                case .hero:     return (8, 4)
                }
            }
        }
    }
}

struct LiquidGlass<S: Shape>: ViewModifier {
    let shape: S
    var tint: Color = PL.C.glassTint
    var elevation: PL.Glass.Elevation = .card
    var dark: Bool = false
    var strokeOpacity: Double = 1

    func body(content: Content) -> some View {
        content.background { glass }
    }

    // The app's original plain surface — warm-white card + hairline — grounded by a soft
    // two-layer warm shadow. No material/sheen layers: they read as a white film on top
    // of light cards.
    private var glass: some View {
        ZStack {
            shape.fill(dark ? PL.C.ink : PL.C.card)
            shape.stroke(PL.C.stroke, lineWidth: 1)
                .opacity(strokeOpacity)
        }
        .compositingGroup()
        .shadow(color: PL.C.shadowAmbient, radius: elevation.ambient.r, y: elevation.ambient.y)
        .shadow(color: PL.C.shadowKey, radius: elevation.key.r, y: elevation.key.y)
    }
}

extension View {
    /// Premium glass background clipped to `shape`.
    func liquidGlass<S: Shape>(_ shape: S,
                               tint: Color = PL.C.glassTint,
                               elevation: PL.Glass.Elevation = .card,
                               dark: Bool = false) -> some View {
        modifier(LiquidGlass(shape: shape, tint: tint, elevation: elevation, dark: dark))
    }

    /// Convenience for the common rounded-rect card.
    func liquidGlassCard(_ radius: CGFloat = PL.R.card,
                         tint: Color = PL.C.glassTint,
                         elevation: PL.Glass.Elevation = .card,
                         dark: Bool = false) -> some View {
        liquidGlass(RoundedRectangle(cornerRadius: radius, style: .continuous),
                    tint: tint, elevation: elevation, dark: dark)
    }
}
