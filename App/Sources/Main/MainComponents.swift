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
            VStack(spacing: 0) {
                Text("LEVEL \(level)")
                    .font(PL.F.sans(8, .bold)).tracking(1).foregroundColor(PL.C.textMuted)
                Text("Faith").font(PL.F.serif(20, .regular)).foregroundColor(PL.C.text)
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

/// A single stat column (big serif number + caps label).
struct StatColumn: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(PL.F.serif(28, .regular)).foregroundColor(PL.C.text)
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
            }
        }
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
                .background(PL.C.card)
                .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
                .plCardStroke()
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
