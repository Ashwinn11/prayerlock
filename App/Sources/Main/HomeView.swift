import SwiftUI

struct HomeView: View {
    @ObservedObject var app = AppModel.shared
    @ObservedObject var screen = ScreenTimeManager.shared
    var onPray: () -> Void
    var onMenu: () -> Void = {}

    private var locked: Bool { app.isLocked }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var nextTimeLabel: String {
        let now = Date()
        let upcoming = app.prayerTimes.map { $0.date }.filter { $0 > now }.min()
        let target = upcoming ?? app.prayerTimes.map { $0.date }.min()
        guard let target else { return "—" }
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return f.string(from: target)
    }

    private var levelProgress: Double {
        let into = app.totalPrayers - (app.companionLevel - 1) * 7
        return Double(max(0, into)) / 7.0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PL.S.xl) {
                header
                heroCard
                PrimaryButton(title: locked ? "Pray now" : "Pray again",
                              style: locked ? .primary : .soft, action: onPray)
                statsRow
                companionCard
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
        }
        .background(PL.C.cream.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Eyebrow(text: greeting)
                Text("Grace and peace")
                    .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.text)
            }
            Spacer()
            Button(action: onMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .medium)).foregroundColor(PL.C.text)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(PL.C.stroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        VStack(spacing: PL.S.md) {
            IllustrationSlot(name: locked ? "home-locked" : "home-unlocked",
                             fallbackSymbol: locked ? "lock.fill" : "bird.fill", size: 96)
            Text(locked ? "Locked" : "Unlocked")
                .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.textOnInk)
            Text(locked ? "Pray to unlock your apps" : "Open until your next prayer time")
                .font(.plSubtitle).foregroundColor(PL.C.textOnInkMuted)
            VStack(spacing: PL.S.sm) {
                HStack {
                    Text(locked ? "Unlock by praying" : "Locks again at")
                        .font(PL.F.sans(14, .medium)).foregroundColor(PL.C.textOnInkMuted)
                    Spacer()
                    Text(nextTimeLabel)
                        .font(PL.F.sans(15, .semibold)).foregroundColor(PL.C.gold)
                }
                Rectangle().fill(PL.C.gold).frame(height: 1.5)
            }
            .padding(.top, PL.S.sm)
        }
        .padding(PL.S.xl)
        .frame(maxWidth: .infinity)
        .background(PL.C.ink)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatColumn(value: "\(app.streak)", label: "STREAK")
            StatColumn(value: "\(app.totalPrayers)", label: "PRAYERS")
            StatColumn(value: "\(max(0, 7 - app.streak))", label: "TO 7 DAYS")
        }
        .padding(.vertical, PL.S.sm)
    }

    private var companionCard: some View {
        HStack(spacing: PL.S.xl) {
            CompanionRing(level: app.companionLevel, progress: levelProgress)
            VStack(alignment: .leading, spacing: 4) {
                Text(app.companionName)
                    .font(PL.F.serif(22, .regular)).foregroundColor(PL.C.text)
                Text("Your companion grows as you pray. \(app.prayersToNextLevel) more to level \(app.companionLevel + 1).")
                    .font(PL.F.sans(14, .regular)).foregroundColor(PL.C.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(PL.S.lg)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }
}
