import SwiftUI

/// The one button used app-wide. Variants cover light screens, dark (insight)
/// screens, and the plain-text "Continue" used on dark backgrounds.
struct PrimaryButton: View {
    enum Style {
        case primary        // dark charcoal pill (light screens)
        case invertedPill   // cream pill on dark screens
        case plainOnInk     // borderless white text (dark insight screens)
    }

    let title: String
    var style: Style = .primary
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            label
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.15), value: enabled)
    }

    @ViewBuilder private var label: some View {
        switch style {
        case .primary:
            Text(title)
                .font(.plButton)
                .foregroundColor(PL.C.buttonText)
                .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                .background(enabled ? PL.C.button : PL.C.buttonDisabled)
                .clipShape(Capsule())
        case .invertedPill:
            Text(title)
                .font(.plButton)
                .foregroundColor(enabled ? PL.C.ink : PL.C.ink.opacity(0.5))
                .frame(maxWidth: .infinity, minHeight: PL.L.buttonHeight)
                .background(enabled ? PL.C.textOnInk : PL.C.textOnInk.opacity(0.4))
                .clipShape(Capsule())
        case .plainOnInk:
            Text(title)
                .font(.plButton)
                .foregroundColor(enabled ? PL.C.textOnInk : PL.C.textOnInkMuted)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }
}
