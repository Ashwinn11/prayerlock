import SwiftUI

/// The one button used app-wide. Variants cover light screens, dark (insight)
/// screens, and the plain-text "Continue" used on dark backgrounds.
struct PrimaryButton: View {
    enum Style {
        case primary        // dark charcoal pill (light screens)
        case invertedPill   // cream pill on dark screens
        case plainOnInk     // borderless white text (dark insight screens)
        case soft           // cream pill, dark text, hairline border (e.g. "Pray again")
    }

    let title: String
    var style: Style = .primary
    var enabled: Bool = true
    var loading: Bool = false
    /// Continuously sweep a highlight band across the fill (money CTA).
    var shimmer: Bool = false
    let action: () -> Void

    private var active: Bool { enabled && !loading }

    var body: some View {
        Button(action: { if active { PL.Haptics.rigid(); action() } }) {
            label
        }
        .buttonStyle(PressableStyle(scale: 0.97, haptic: false))
        .disabled(!active)
        .animation(PL.Motion.smooth, value: enabled)
        .animation(PL.Motion.smooth, value: loading)
    }

    @ViewBuilder private var content: some View {
        if loading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(style == .primary ? PL.C.buttonText : PL.C.text)
        } else {
            Text(title)
        }
    }

    @ViewBuilder private var label: some View {
        switch style {
        case .primary:
            content
                .font(.plButton)
                .foregroundColor(PL.C.buttonText)
                .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                .background(
                    Capsule().fill(active ? PL.C.button : PL.C.buttonDisabled)
                        .plShimmer(active: shimmer && active)
                )
                .clipShape(Capsule())
                .shadow(color: PL.C.shadowKey, radius: 10, y: 5)
                .plGlow(PL.C.goldGlow, radius: 12, active: shimmer && active)
        case .invertedPill:
            content
                .font(.plButton)
                .foregroundColor(active ? PL.C.ink : PL.C.ink.opacity(0.5))
                .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                .background(active ? PL.C.textOnInk : PL.C.textOnInk.opacity(0.4))
                .clipShape(Capsule())
        case .plainOnInk:
            content
                .font(.plButton)
                .foregroundColor(active ? PL.C.textOnInk : PL.C.textOnInkMuted)
                .frame(maxWidth: .infinity, minHeight: 44)
        case .soft:
            content
                .font(.plButton)
                .foregroundColor(PL.C.text)
                .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                .background(Capsule().fill(PL.C.card))
                .overlay(Capsule().stroke(PL.C.stroke, lineWidth: 1))
                .clipShape(Capsule())
                .shadow(color: PL.C.shadowAmbient, radius: 12, y: 6)
        }
    }
}
