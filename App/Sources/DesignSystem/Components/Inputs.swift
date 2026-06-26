import SwiftUI

// MARK: - Option row + selectable list

struct OptionRow: View {
    let title: String
    let selected: Bool
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
                Image(systemName: "circle.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
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
                OptionRow(title: option, selected: selection.contains(option)) {
                    toggle(option)
                }
            }
        }
    }

    private var isMulti: Bool { if case .multi = mode { true } else { false } }

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
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var binding: Binding<Double> {
        Binding(get: { Double(value) }, set: { value = Int($0.rounded()) })
    }

    var body: some View {
        VStack(spacing: PL.S.xxl) {
            VStack(spacing: PL.S.xs) {
                Text("\(value)")
                    .font(PL.F.serif(sizeClass == .regular ? 118 : 92, .regular))
                    .foregroundColor(theme.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.18), value: value)
                Text(unit)
                    .font(.plSubtitle)
                    .foregroundColor(theme.textMuted)
            }
            VStack(spacing: PL.S.sm) {
                // Native iOS slider (matches the iOS 26 redesigned handle).
                Slider(value: binding,
                       in: Double(range.lowerBound)...Double(range.upperBound),
                       step: 1)
                    .tint(PL.C.gold)
                HStack {
                    Text("\(range.lowerBound)")
                    Spacer()
                    Text("\(range.upperBound)")
                }
                .font(.plSubtitle)
                .foregroundColor(theme.textMuted)
            }
        }
    }
}

// MARK: - Emoji mood slider (relationship / feeling check-ins)

struct MoodStop {
    let emoji: String
    let word: String
}

enum MoodStops {
    static let feeling = [
        MoodStop(emoji: "😞", word: "awful"),
        MoodStop(emoji: "😕", word: "low"),
        MoodStop(emoji: "😐", word: "okay"),
        MoodStop(emoji: "🙂", word: "good"),
        MoodStop(emoji: "😄", word: "great"),
    ]
    static let relationship = [
        MoodStop(emoji: "😔", word: "distant"),
        MoodStop(emoji: "😕", word: "strained"),
        MoodStop(emoji: "😐", word: "okay"),
        MoodStop(emoji: "🙂", word: "good"),
        MoodStop(emoji: "🥰", word: "close"),
    ]
}

/// Big emoji + native gold slider + word label. Drives prayer/verse selection.
struct EmojiSlider: View {
    let stops: [MoodStop]
    @Binding var index: Int
    var theme: ScreenTheme = .light
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var clamped: Int { min(max(index, 0), stops.count - 1) }
    private var emojiSize: CGFloat { sizeClass == .regular ? 90 : 68 }

    var body: some View {
        VStack(spacing: PL.S.xl) {
            Text(stops[clamped].emoji)
                .font(.system(size: emojiSize))
                .id(clamped)
                .transition(.scale.combined(with: .opacity))
                .animation(.snappy(duration: 0.2), value: clamped)
            Slider(value: Binding(get: { Double(clamped) },
                                  set: { index = Int($0.rounded()) }),
                   in: 0...Double(stops.count - 1), step: 1)
                .tint(PL.C.gold)
            Text(stops[clamped].word)
                .font(.plSubtitle)
                .foregroundColor(theme.textMuted)
                .contentTransition(.opacity)
                .animation(.snappy(duration: 0.2), value: clamped)
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
            .font(PL.F.serif(22, .regular))
            .foregroundColor(theme.textPrimary)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .padding(.horizontal, PL.S.xl)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(PL.C.card)
            .clipShape(RoundedRectangle(cornerRadius: PL.R.field, style: .continuous))
            .plCardStroke(PL.R.field)
    }
}
