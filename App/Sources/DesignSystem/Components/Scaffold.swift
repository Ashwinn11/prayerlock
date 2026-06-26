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
    var style: PrimaryButton.Style = .primary
    var enabled: Bool = true
    var action: () -> Void
}

/// Thin gold progress track.
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

/// Top bar: circular back button + optional progress.
struct OnboardingTopBar: View {
    var showBack: Bool
    var progress: Double?
    var tint: Color
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: PL.S.lg) {
            if showBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(tint)
                        .frame(width: PL.L.backButton, height: PL.L.backButton)
                        .overlay(Circle().stroke(tint.opacity(0.22), lineWidth: 1.2))
                }
                .buttonStyle(.plain)
            }
            if let progress {
                ProgressBar(value: progress)
            } else {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: PL.L.backButton)
    }
}

/// The universal onboarding/flow screen container.
/// Light or dark theme, optional back + progress, centered or top-aligned content,
/// pinned bottom button.
struct OnbScaffold<Content: View>: View {
    var theme: ScreenTheme = .light
    var showBack: Bool = true
    var progress: Double? = nil
    var centered: Bool = false
    var onBack: () -> Void = {}
    var primary: ButtonConfig? = nil
    @ViewBuilder var content: () -> Content

    private var hasTopBar: Bool { showBack || progress != nil }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                if hasTopBar {
                    OnboardingTopBar(showBack: showBack, progress: progress,
                                     tint: theme.textPrimary, onBack: onBack)
                        .padding(.top, PL.S.sm)
                        .padding(.bottom, PL.S.xl)
                } else {
                    Spacer().frame(height: PL.S.xl)
                }

                if centered {
                    Spacer(minLength: 0)
                    content()
                    Spacer(minLength: 0)
                } else {
                    content()
                    Spacer(minLength: PL.S.lg)
                }

                if let primary {
                    PrimaryButton(title: primary.title, style: primary.style,
                                  enabled: primary.enabled, action: primary.action)
                        .padding(.bottom, PL.L.bottomBar)
                }
            }
            .padding(.horizontal, PL.L.margin)
        }
        .preferredColorScheme(theme.colorScheme)
    }
}
