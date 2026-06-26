import SwiftUI

/// Editable list of prayer times — rows + add button, tap a row to change it.
/// Reused by onboarding setup and Settings.
struct TimeListEditor: View {
    @Binding var times: [PrayerTime]
    var theme: ScreenTheme = .light
    @State private var editing: PrayerTime?

    var body: some View {
        VStack(spacing: PL.S.md) {
            ForEach(times) { t in
                Button { editing = t } label: { row(t) }
                    .buttonStyle(.plain)
            }
            addButton
        }
        .sheet(item: $editing) { t in
            TimeEditSheet(time: t) { updated in
                if let i = times.firstIndex(where: { $0.id == updated.id }) {
                    times[i] = updated
                }
            } onDelete: {
                times.removeAll { $0.id == t.id }
            }
            .presentationDetents([.height(360)])
        }
    }

    private func row(_ t: PrayerTime) -> some View {
        HStack {
            Text(t.label)
                .font(PL.F.serif(22, .regular))
                .foregroundColor(PL.C.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(PL.C.textMuted)
        }
        .padding(.horizontal, PL.S.xl)
        .frame(height: PL.L.optionRow)
        .frame(maxWidth: .infinity)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }

    private var addButton: some View {
        Button {
            times.append(PrayerTime(hour: 9, minute: 0))
        } label: {
            HStack(spacing: PL.S.sm) {
                Image(systemName: "plus")
                Text("Add prayer time")
            }
            .font(PL.F.sans(16, .semibold))
            .foregroundColor(PL.C.gold)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .stroke(PL.C.gold.opacity(0.4), style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TimeEditSheet: View {
    let time: PrayerTime
    let onSave: (PrayerTime) -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date

    init(time: PrayerTime, onSave: @escaping (PrayerTime) -> Void, onDelete: @escaping () -> Void) {
        self.time = time; self.onSave = onSave; self.onDelete = onDelete
        _date = State(initialValue: time.date)
    }

    var body: some View {
        VStack(spacing: PL.S.xl) {
            Text("Prayer time")
                .font(PL.F.serif(24, .regular))
                .foregroundColor(PL.C.text)
                .padding(.top, PL.S.xl)
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
            HStack(spacing: PL.S.md) {
                Button("Delete") { onDelete(); dismiss() }
                    .font(PL.F.sans(16, .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(PL.C.card)
                    .clipShape(Capsule())
                Button("Save") {
                    var t = time; let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                    t.hour = c.hour ?? t.hour; t.minute = c.minute ?? t.minute
                    onSave(t); dismiss()
                }
                .font(.plButton)
                .foregroundColor(PL.C.buttonText)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(PL.C.button)
                .clipShape(Capsule())
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.bottom, PL.S.xl)
        }
        .background(PL.C.cream.ignoresSafeArea())
    }
}
