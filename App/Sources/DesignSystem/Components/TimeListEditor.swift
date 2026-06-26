import SwiftUI

/// Editable list of prayer times — tappable inline .compact DatePicker (iOS 26 Liquid Glass)
/// with a minus button to remove, plus an "Add prayer time" button.
struct TimeListEditor: View {
    @Binding var times: [PrayerTime]
    var theme: ScreenTheme = .light

    var body: some View {
        VStack(spacing: PL.S.md) {
            ForEach($times) { $time in
                HStack {
                    DatePicker("", selection: Binding(
                        get: { time.date },
                        set: { d in
                            let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                            time.hour = c.hour ?? 0
                            time.minute = c.minute ?? 0
                        }
                    ), displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(PL.C.gold)
                    Spacer()
                    Button {
                        times.removeAll { $0.id == time.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(PL.C.textMuted)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, PL.S.lg)
                .frame(height: 60)
                .background(PL.C.card)
                .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
                .plCardStroke()
            }
            addButton
        }
    }

    private var addButton: some View {
        Button {
            times.append(PrayerTime(hour: 9, minute: 0))
        } label: {
            HStack(spacing: PL.S.sm) {
                Image(systemName: "plus.circle.fill")
                Text("Add prayer time")
            }
            .font(PL.F.sans(16, .semibold))
            .foregroundColor(PL.C.gold)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .stroke(PL.C.gold.opacity(0.4), style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
            )
        }
        .buttonStyle(.plain)
    }
}
