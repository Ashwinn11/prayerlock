import SwiftUI
import FamilyControls

struct SettingsView: View {
    @ObservedObject var app = AppModel.shared
    @ObservedObject var screen = ScreenTimeManager.shared
    @State private var showPicker = false
    @State private var editingTime: PrayerTime?
    @State private var editingReminder = false
    @State private var confirmDelete = false
    @State private var legal: LegalDoc?
    @State private var showAuthAlert = false

    private var reminderLabel: String {
        let c = DateComponents(hour: app.reminderHour, minute: app.reminderMinute)
        let d = Calendar.current.date(from: c) ?? Date()
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f.string(from: d)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                Text("Settings")
                    .font(PL.F.serif(34, .regular)).foregroundColor(PL.C.text)
                blocking
                prayerTimes
                reminders
                about
                testing
                data
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
        }
        .background(PL.C.cream.ignoresSafeArea())
        .familyActivityPicker(isPresented: $showPicker, selection: $screen.selection)
        .onChange(of: screen.selection) { newValue in
            BlockedSelectionStore().save(newValue)
        }
        .sheet(item: $editingTime) { t in
            TimePickerSheet(date: t.date) { newDate in
                if let i = app.prayerTimes.firstIndex(where: { $0.id == t.id }) {
                    let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    app.prayerTimes[i].hour = c.hour ?? t.hour
                    app.prayerTimes[i].minute = c.minute ?? t.minute
                    screen.reschedule(times: app.prayerTimes)
                }
            }
        }
        .sheet(isPresented: $editingReminder) {
            TimePickerSheet(date: reminderDate) { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                app.reminderHour = c.hour ?? app.reminderHour
                app.reminderMinute = c.minute ?? app.reminderMinute
            }
        }
        .sheet(item: $legal) { LegalView(doc: $0) }
        .alert("Delete all data?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                screen.clearAll()
                app.deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This resets your streak, journal, and onboarding. This can't be undone.")
        }
        .alert("Screen Time access needed", isPresented: $showAuthAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("To choose apps to block, allow Prayer Lock to use Screen Time access.")
        }
    }

    private var reminderDate: Date {
        Calendar.current.date(from: DateComponents(hour: app.reminderHour, minute: app.reminderMinute)) ?? Date()
    }

    /// FamilyActivityPicker only works once authorized — ensure auth first.
    private func openPicker() {
        if screen.isAuthorized {
            showPicker = true
        } else {
            Task {
                await screen.requestAuthorization()
                if screen.isAuthorized { showPicker = true } else { showAuthAlert = true }
            }
        }
    }

    // MARK: Sections

    private var blocking: some View {
        SettingsSection(title: "Blocking") {
            Button { openPicker() } label: {
                SettingsRow(label: "Blocked apps") {
                    HStack(spacing: 6) {
                        Text("\(screen.blockedCount) selected")
                            .font(PL.F.sans(15, .medium)).foregroundColor(PL.C.textMuted)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(PL.C.textMuted)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var prayerTimes: some View {
        VStack(alignment: .leading, spacing: PL.S.sm) {
            Eyebrow(text: "Prayer Times").padding(.leading, PL.S.xs)
            Text("Apps lock at these times until you pray.")
                .font(.plSubtitle).foregroundColor(PL.C.textMuted).padding(.leading, PL.S.xs)
            VStack(spacing: PL.S.md) {
                ForEach($app.prayerTimes) { $t in
                    HStack {
                        Button { editingTime = t } label: { ValuePill(text: t.label) }
                            .buttonStyle(.plain)
                        Spacer()
                        Toggle("", isOn: $t.enabled).labelsHidden().tint(PL.C.gold)
                    }
                    .padding(.horizontal, PL.S.lg)
                    .frame(height: 60)
                    .background(PL.C.card)
                    .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
                    .plCardStroke()
                }
                addTimeButton
            }
        }
    }

    private var addTimeButton: some View {
        Button {
            app.prayerTimes.append(PrayerTime(hour: 9, minute: 0))
            screen.reschedule(times: app.prayerTimes)
        } label: {
            HStack(spacing: PL.S.sm) {
                Image(systemName: "plus.circle.fill")
                Text("Add prayer time")
            }
            .font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.gold)
            .frame(height: 56).frame(maxWidth: .infinity)
            .overlay(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                .stroke(PL.C.gold.opacity(0.4), style: StrokeStyle(lineWidth: 1.4, dash: [5, 4])))
        }
        .buttonStyle(.plain)
    }

    private var reminders: some View {
        SettingsSection(title: "Reminders") {
            SettingsRow(label: "Daily reminder") {
                Toggle("", isOn: $app.dailyReminderEnabled).labelsHidden().tint(PL.C.gold)
            }
            SettingsRowDivider()
            Button { editingReminder = true } label: {
                SettingsRow(label: "Time") { ValuePill(text: reminderLabel) }
            }
            .buttonStyle(.plain)
        }
    }

    private var about: some View {
        SettingsSection(title: "About") {
            navRow("Privacy Policy") { legal = .privacy }
            SettingsRowDivider()
            navRow("Terms of Use") { legal = .terms }
            SettingsRowDivider()
            SettingsRow(label: "Version") {
                Text("v1.0").font(PL.F.sans(15, .medium)).foregroundColor(PL.C.textMuted)
            }
        }
    }

    private func navRow(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsRow(label: label) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(PL.C.textMuted)
            }
        }
        .buttonStyle(.plain)
    }

    private var testing: some View {
        SettingsSection(title: "Testing") {
            Button { screen.lockNow() } label: {
                SettingsRow(label: "Block now") {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14)).foregroundColor(PL.C.gold)
                }
            }
            .buttonStyle(.plain)
            SettingsRowDivider()
            Button { screen.unlockNow() } label: {
                SettingsRow(label: "Unlock now") {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 14)).foregroundColor(PL.C.gold)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var data: some View {
        SettingsSection(title: "Data") {
            Button { confirmDelete = true } label: {
                SettingsRow(label: "Delete all data", labelColor: .red) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

/// Reusable wheel time picker sheet.
struct TimePickerSheet: View {
    let initial: Date
    let onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date

    init(date: Date, onSave: @escaping (Date) -> Void) {
        self.initial = date; self.onSave = onSave
        _date = State(initialValue: date)
    }

    var body: some View {
        VStack(spacing: PL.S.xl) {
            Text("Set time")
                .font(PL.F.serif(24, .regular)).foregroundColor(PL.C.text).padding(.top, PL.S.xl)
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel).labelsHidden()
            PrimaryButton(title: "Save") { onSave(date); dismiss() }
                .padding(.horizontal, PL.L.margin).padding(.bottom, PL.S.xl)
        }
        .background(PL.C.cream.ignoresSafeArea())
        .presentationDetents([.height(340)])
    }
}
