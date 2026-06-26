import SwiftUI

/// A scheduled daily prayer time (hour/minute).
struct PrayerTime: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var hour: Int
    var minute: Int

    var date: Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    var label: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
    static func from(_ date: Date) -> PrayerTime {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return PrayerTime(hour: c.hour ?? 8, minute: c.minute ?? 0)
    }
}

/// Runtime + persisted state shared across the app. Key fields mirror into the
/// app group so the extensions can read them.
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("companionName") var companionName: String = "Grace"
    @AppStorage("denomination") var denomination: String = ""

    // Progress / gamification
    @AppStorage("streak") var streak: Int = 0
    @AppStorage("totalPrayers") var totalPrayers: Int = 0
    @AppStorage("companionLevel") var companionLevel: Int = 1
    @AppStorage("faithPoints") var faithPoints: Int = 0
    @AppStorage("lastPrayerEpoch") var lastPrayerEpoch: Double = 0
    @AppStorage("planStartEpoch") var planStartEpoch: Double = 0

    @Published var prayerTimes: [PrayerTime] = AppModel.loadTimes() {
        didSet { AppModel.saveTimes(prayerTimes) }
    }

    @Published var journal: [JournalEntry] = JournalStore.load() {
        didSet { JournalStore.save(journal) }
    }

    // MARK: Lock state (mirrors the shared ShieldController flags)
    var isLocked: Bool { PL.defaults.bool(forKey: "isLocked") }

    /// Prayers needed to reach the next companion level.
    var prayersToNextLevel: Int { max(0, companionLevel * 7 - totalPrayers) }

    var planProgress: Double {
        guard planStartEpoch > 0 else { return 0 }
        let days = Date().timeIntervalSince1970 - planStartEpoch
        return min(1, max(0, days / (90 * 86_400)))
    }

    // MARK: Persistence helpers (prayer times live in the app group)
    private static func loadTimes() -> [PrayerTime] {
        guard let data = PL.defaults.data(forKey: "prayerTimes"),
              let times = try? JSONDecoder().decode([PrayerTime].self, from: data),
              !times.isEmpty
        else {
            return [PrayerTime(hour: 8, minute: 0),
                    PrayerTime(hour: 12, minute: 0),
                    PrayerTime(hour: 18, minute: 0)]
        }
        return times
    }
    private static func saveTimes(_ times: [PrayerTime]) {
        if let data = try? JSONEncoder().encode(times) {
            PL.defaults.set(data, forKey: "prayerTimes")
        }
    }

    /// Record a completed prayer: bump streak/level, unlock apps, save journal.
    func completePrayer(entry: JournalEntry) {
        let cal = Calendar.current
        let last = Date(timeIntervalSince1970: lastPrayerEpoch)
        if lastPrayerEpoch == 0 {
            streak = 1
        } else if cal.isDateInToday(last) {
            // same day, keep streak
        } else if cal.isDateInYesterday(last) {
            streak += 1
        } else {
            streak = 1
        }
        lastPrayerEpoch = Date().timeIntervalSince1970
        totalPrayers += 1
        faithPoints += 10
        if totalPrayers >= companionLevel * 7 { companionLevel += 1 }
        journal.insert(entry, at: 0)
        ShieldController().unlock()
    }
}
