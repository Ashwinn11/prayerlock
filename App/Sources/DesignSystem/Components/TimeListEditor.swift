import SwiftUI

/// Editable list of prayer times — matches the Settings design: each time is a
/// tappable pill that opens the wheel picker, with a minus button to remove it,
/// plus an "Add prayer time" button.
struct TimeListEditor: View {
    @Binding var times: [PrayerTime]
    var theme: ScreenTheme = .light
    @State private var editing: PrayerTime?

    var body: some View {
        VStack(spacing: PL.S.md) {
            ForEach(times) { t in
                HStack {
                    Button { editing = t } label: { ValuePill(text: t.label) }
                        .buttonStyle(.plain)
                    Spacer()
                    Button { times.removeAll { $0.id == t.id } } label: {
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
        .sheet(item: $editing) { t in
            TimePickerSheet(date: t.date) { newDate in
                if let i = times.firstIndex(where: { $0.id == t.id }) {
                    let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    times[i].hour = c.hour ?? t.hour
                    times[i].minute = c.minute ?? t.minute
                }
            }
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
