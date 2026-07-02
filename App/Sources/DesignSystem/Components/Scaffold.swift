import SwiftUI

enum ScreenTheme {
    case light, dark
    var background: Color { self == .light ? PL.C.cream : PL.C.ink }
    var textPrimary: Color { self == .light ? PL.C.text : PL.C.textOnInk }
    var textMuted: Color { self == .light ? PL.C.textMuted : PL.C.textOnInkMuted }
    var colorScheme: ColorScheme { self == .light ? .light : .dark }
}

/// Bottom button configuration passed to a scaffold.
struct ButtonConfig {
    var title: String
    var style: PrimaryButton.Style = .primary   // kept for call-site compat; footer ignores it
    var enabled: Bool = true
    var loading: Bool = false
    var action: () -> Void
}

/// Thin gold progress track (prayer session, main app — not onboarding).
struct ProgressBar: View {
    let value: Double // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(PL.C.track)
                Capsule().fill(PL.C.gold)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: PL.L.progressBar)
        .animation(.easeInOut(duration: 0.25), value: value)
    }
}

/// Step dots shown during the onboarding question segment (10 question steps).
struct OnbDots: View {
    let progress: Double   // 0...1 as returned by Onboarding.progress
    private let total = 10
    private var filled: Int { max(0, Int((progress * Double(total)).rounded())) }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i < filled ? PL.C.gold : PL.C.track)
                    .frame(width: i < filled ? 8 : 6, height: i < filled ? 8 : 6)
                    .animation(PL.Motion.bounce, value: filled)
            }
        }
    }
}

/// The universal onboarding/flow screen container.
///
/// Navigation lives entirely in the footer:
///   [← back]  ········  [Continue →]
/// with optional progress dots on the row above when `progress != nil`.
///
/// Content alignment:
///   `centered: false` (default) → content pinned near top, below a fixed top margin.
///                                  Best for form / list / card-heavy screens.
///   `centered: true`            → Spacer above+below content so it floats vertically.
///                                  Best for illustration / sparse-content screens.
struct OnbScaffold<Content: View>: View {
    var theme: ScreenTheme = .light
    var showBack: Bool = true
    var progress: Double? = nil
    var centered: Bool = false
    var onBack: () -> Void = {}
    var primary: ButtonConfig? = nil
    /// Overlay warm volumetric god-rays on the background (dark insight beats).
    var godRays: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                Spacer(minLength: PL.S.xl)

                content()

                Spacer(minLength: PL.S.lg)

                footer
            }
            .padding(.horizontal, PL.L.margin)
            .plContent()
        }
        .preferredColorScheme(theme.colorScheme)
    }

    @ViewBuilder private var background: some View {
        if godRays {
            ScreenBackground(theme: theme)
                .plGodRays(source: .init(x: 0.5, y: 0.16), strength: theme == .dark ? 1 : 0.55)
        } else {
            ScreenBackground(theme: theme)
        }
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: PL.S.lg) {
            if let progress {
                OnbDots(progress: progress)
            }

            HStack(spacing: 0) {
                backButton
                Spacer()
                if let primary { continueButton(primary, extraWidth: showBack ? 0 : PL.L.backButton) }
            }
        }
        .padding(.bottom, PL.L.bottomBar)
    }

    @ViewBuilder private var backButton: some View {
        if showBack {
            Button(action: { PL.Haptics.light(); onBack() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                    .frame(width: PL.L.backButton, height: PL.L.backButton)
                    .overlay(Circle().stroke(theme.textPrimary.opacity(0.22), lineWidth: 1.2))
            }
            .buttonStyle(.pressable)
        } else {
            EmptyView()
        }
    }

    private func continueButton(_ cfg: ButtonConfig, extraWidth: CGFloat = 0) -> some View {
        let isDark = theme == .dark
        let textColor: Color = isDark ? PL.C.textOnInk : labelColor(cfg.style)
        let bg: Color = isDark ? .clear : bgColor(cfg.style, enabled: cfg.enabled)
        let strokeColor = theme.textPrimary.opacity(0.22)

        return Button {
            guard cfg.enabled && !cfg.loading else { return }
            PL.Haptics.rigid()
            cfg.action()
        } label: {
            ZStack {
                Capsule()
                    .fill(bg)
                    .shadow(color: isDark ? .clear : PL.C.shadowKey, radius: 8, y: 4)
                if isDark {
                    Capsule()
                        .strokeBorder(strokeColor, lineWidth: 1.2)
                }
                if cfg.loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(textColor)
                        .scaleEffect(0.8)
                } else {
                    Text(cfg.title)
                        .font(PL.F.sans(16, .semibold))
                        .foregroundColor(textColor)
                    .padding(.horizontal, PL.S.xl)
                }
            }
            .frame(minWidth: cfg.loading ? 80 : 160 + extraWidth, minHeight: PL.L.backButton, maxHeight: PL.L.backButton)
            .opacity(cfg.enabled ? 1 : 0.4)
        }
        .buttonStyle(PressableStyle(scale: 0.95, haptic: false))
        .animation(PL.Motion.smooth, value: cfg.enabled)
        .animation(PL.Motion.smooth, value: cfg.loading)
    }

    private func labelColor(_ style: PrimaryButton.Style) -> Color {
        switch style {
        case .primary:          return PL.C.buttonText
        case .invertedPill:     return PL.C.ink
        case .plainOnInk:       return PL.C.textOnInk
        case .soft:             return PL.C.text
        }
    }

    private func bgColor(_ style: PrimaryButton.Style, enabled: Bool) -> Color {
        switch style {
        case .primary:          return enabled ? PL.C.button : PL.C.buttonDisabled
        case .invertedPill:     return enabled ? PL.C.textOnInk : PL.C.textOnInk.opacity(0.4)
        case .plainOnInk:       return .clear
        case .soft:             return PL.C.card
        }
    }
}
