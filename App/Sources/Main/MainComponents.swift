import SwiftUI

// MARK: - Floating tab bar

enum PLTab: String, CaseIterable, Identifiable {
    case home, bible, journal, settings
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .bible: return "book.closed.fill"
        case .journal: return "checkmark.seal.fill"
        case .settings: return "gearshape.fill"
        }
    }
    var iconInactive: String {
        switch self {
        case .home: return "house"
        case .bible: return "book.closed"
        case .journal: return "checkmark.seal"
        case .settings: return "gearshape"
        }
    }
}

/// Floating liquid-glass tab bar: a gold selection pill morphs between items
/// (matched geometry), icons bounce on select, every switch ticks.
struct PLTabBar: View {
    @Binding var selected: PLTab
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 2) {
            ForEach(PLTab.allCases) { tab in
                item(tab)
            }
        }
        .padding(5)
        .liquidGlass(Capsule(), elevation: .floating)
    }

    private func item(_ tab: PLTab) -> some View {
        let active = tab == selected
        return Button {
            guard !active else { return }
            PL.Haptics.selection()
            withPLAnimation(PL.Motion.bounce) { selected = tab }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: active ? tab.icon : tab.iconInactive)
                    .font(.system(size: 17, weight: .medium))
                    .symbolEffect(.bounce, value: active)
                    .frame(height: 22)
                Text(tab.title)
                    .font(PL.F.sans(10, .semibold))
            }
            .foregroundColor(active ? PL.C.text : PL.C.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background {
                if active {
                    Capsule()
                        .fill(PL.C.gold.opacity(0.15))
                        .overlay(Capsule().stroke(PL.C.gold.opacity(0.30), lineWidth: 1))
                        .matchedGeometryEffect(id: "tab-pill", in: ns)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Home pieces

/// Circular faith/level progress ring with centered label.
struct CompanionRing: View {
    let level: Int
    let progress: Double
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var diameter: CGFloat { sizeClass == .regular ? 120 : 92 }
    var body: some View {
        ZStack {
            Circle().stroke(PL.C.track, lineWidth: 5)
            Circle().trim(from: 0, to: max(0.02, min(1, progress)))
                .stroke(PL.C.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: PL.C.goldGlow.opacity(0.35), radius: 5)
                .animation(PL.Motion.gentle, value: progress)
            VStack(spacing: 0) {
                Text("LEVEL \(level)")
                    .font(PL.F.sans(8, .bold)).tracking(1).foregroundColor(PL.C.textMuted)
                Text("Faith").font(PL.F.serif(20, .regular)).foregroundColor(PL.C.text)
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

/// A single stat column (big rolling serif number + caps label).
struct StatColumn: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            RollingNumber(value: value, font: PL.F.serif(28, .regular))
            Text(label).font(PL.F.sans(11, .bold)).tracking(1).foregroundColor(PL.C.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Heatmap (prayer journey / 90-day plan)

struct HeatmapGrid: View {
    let total: Int
    let columns: Int
    let done: Int
    var fillFromEnd: Bool = false
    var emptyColor: Color = Color.white.opacity(0.07)

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduce

    private func filled(_ i: Int) -> Bool {
        fillFromEnd ? i >= total - done : i < done
    }
    var body: some View {
        let grid = Array(repeating: GridItem(.flexible(), spacing: 7), count: columns)
        LazyVGrid(columns: grid, spacing: 7) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(filled(i) ? PL.C.gold : emptyColor)
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(appeared ? 1 : 0.2)
                    .opacity(appeared ? 1 : 0)
                    .animation(reduce ? .easeOut(duration: 0.2)
                                      : PL.Motion.bounce.delay(Double(i) * 0.006),
                               value: appeared)
            }
        }
        .onAppear { appeared = true }
        .animation(PL.Motion.bounce, value: total)   // 7-day ↔ 90-day expand morphs
    }
}

// MARK: - Settings building blocks

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: PL.S.sm) {
            Eyebrow(text: title).padding(.leading, PL.S.xs)
            VStack(spacing: 0) { content }
                .liquidGlassCard(PL.R.card)
        }
    }
}

struct SettingsRowDivider: View {
    var body: some View { Divider().background(PL.C.stroke).padding(.leading, PL.S.lg) }
}

/// Generic settings row: label + trailing content.
struct SettingsRow<Trailing: View>: View {
    let label: String
    var labelColor: Color = PL.C.text
    @ViewBuilder var trailing: Trailing
    var body: some View {
        HStack {
            Text(label).font(PL.F.sans(16, .medium)).foregroundColor(labelColor)
            Spacer()
            trailing
        }
        .padding(.horizontal, PL.S.lg)
        .frame(minHeight: 54)
    }
}

/// Small gray value pill (e.g. "8:00 AM").
struct ValuePill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(PL.F.sans(15, .semibold)).foregroundColor(PL.C.text)
            .padding(.horizontal, PL.S.md).padding(.vertical, 6)
            .background(PL.C.track.opacity(0.5))
            .clipShape(Capsule())
    }
}
