import SwiftUI

// MARK: - Option row + selectable list

struct OptionRow: View {
    let title: String
    let selected: Bool
    var multi: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PL.S.lg) {
                Text(title)
                    .font(.plOption)
                    .foregroundColor(PL.C.text)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: PL.S.md)
                indicator
            }
            .padding(.horizontal, PL.S.xl)
            .padding(.vertical, PL.S.lg)
            .frame(minHeight: PL.L.optionRow)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PL.C.card)
            .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .stroke(selected ? PL.C.gold : PL.C.stroke, lineWidth: selected ? 1.6 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.12), value: selected)
    }

    @ViewBuilder private var indicator: some View {
        ZStack {
            Circle()
                .stroke(selected ? PL.C.gold : PL.C.track, lineWidth: 1.6)
                .frame(width: 24, height: 24)
            if selected {
                Circle().fill(PL.C.gold).frame(width: 24, height: 24)
                Image(systemName: multi ? "checkmark" : "circle.fill")
                    .font(.system(size: multi ? 12 : 8, weight: .bold))
                    .foregroundColor(multi ? .white : .white)
            }
        }
    }
}

enum SelectMode: Equatable {
    case single
    case multi(max: Int?)
}

/// A vertical list of selectable rows. Single- or multi-select (with optional cap).
struct SelectableList: View {
    let options: [String]
    @Binding var selection: Set<String>
    var mode: SelectMode = .single

    var body: some View {
        VStack(spacing: PL.S.md) {
            ForEach(options, id: \.self) { option in
                OptionRow(title: option, selected: selection.contains(option),
                          multi: isMulti) {
                    toggle(option)
                }
            }
        }
    }

    private var isMulti: Bool { if case .multi = mode { return true } else { return false } }

    private func toggle(_ option: String) {
        switch mode {
        case .single:
            selection = [option]
        case .multi(let max):
            if selection.contains(option) {
                selection.remove(option)
            } else {
                if let max, selection.count >= max { return }
                selection.insert(option)
            }
        }
    }
}

// MARK: - Big value slider (hours/day, days/week)

struct ValueSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var unit: String
    var theme: ScreenTheme = .light

    private let thumbW: CGFloat = 40
    private let thumbH: CGFloat = 30
    private let trackH: CGFloat = 6

    var body: some View {
        VStack(spacing: PL.S.xxl) {
            VStack(spacing: PL.S.xs) {
                Text("\(value)")
                    .font(PL.F.serif(96, .regular))
                    .foregroundColor(theme.textPrimary)
                    .monospacedDigit()
                Text(unit)
                    .font(.plSubtitle)
                    .foregroundColor(theme.textMuted)
            }
            slider
        }
    }

    private var slider: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let span = w - thumbW
            let pct = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
            let x = span * pct
            ZStack(alignment: .leading) {
                Capsule().fill(PL.C.track).frame(height: trackH)
                Capsule().fill(PL.C.gold).frame(width: x + thumbW / 2, height: trackH)
                Capsule()
                    .fill(Color.white)
                    .frame(width: thumbW, height: thumbH)
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    .offset(x: x)
            }
            .frame(height: thumbH)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let raw = (g.location.x - thumbW / 2) / span
                        let clamped = min(1, max(0, raw))
                        let newVal = range.lowerBound +
                            Int((clamped * CGFloat(range.upperBound - range.lowerBound)).rounded())
                        if newVal != value { value = newVal }
                    }
            )
        }
        .frame(height: thumbH)
        .overlay(alignment: .bottomLeading) {
            Text("\(range.lowerBound)").font(.plSubtitle).foregroundColor(theme.textMuted)
                .offset(y: 28)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(range.upperBound)").font(.plSubtitle).foregroundColor(theme.textMuted)
                .offset(y: 28)
        }
    }
}

// MARK: - Text field

struct PLTextField: View {
    let placeholder: String
    @Binding var text: String
    var theme: ScreenTheme = .light

    var body: some View {
        TextField("", text: $text, prompt:
            Text(placeholder).foregroundColor(theme.textMuted))
            .font(PL.F.serif(24, .regular))
            .foregroundColor(theme.textPrimary)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .padding(.vertical, PL.S.xl)
            .padding(.horizontal, PL.S.xl)
            .frame(maxWidth: .infinity)
            .background(PL.C.card)
            .clipShape(RoundedRectangle(cornerRadius: PL.R.field, style: .continuous))
            .plCardStroke(PL.R.field)
    }
}
