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
    let action: () -> Void

    private var active: Bool { enabled && !loading }

    var body: some View {
        Button(action: { if active { action() } }) {
            label
        }
        .buttonStyle(.plain)
        .disabled(!active)
        .animation(.easeInOut(duration: 0.15), value: enabled)
        .animation(.easeInOut(duration: 0.15), value: loading)
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
                .background(active ? PL.C.button : PL.C.buttonDisabled)
                .clipShape(Capsule())
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
                .background(PL.C.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(PL.C.stroke, lineWidth: 1))
        }
    }
}
