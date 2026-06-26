import Foundation

/// A saved prayer + reflection in the user's journal.
struct JournalEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String              // e.g. "Be Still"
    var prayerText: String
    var scriptureText: String
    var scriptureRef: String       // e.g. "PSALMS 46:10"
    var reflection: String = ""
    var date: Date = Date()
    var illustration: String? = nil   // asset name for the journal thumbnail

    var timeLabel: String {
        let f = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            f.dateFormat = "h:mm a"
            return "Today • \(f.string(from: date))"
        }
        f.dateFormat = "MMM d • h:mm a"
        return f.string(from: date)
    }

    var fullDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return f.string(from: date)
    }
}

enum JournalStore {
    private static let key = "journalEntries"
    static func load() -> [JournalEntry] {
        guard let data = PL.defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else { return [] }
        return entries
    }
    static func save(_ entries: [JournalEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            PL.defaults.set(data, forKey: key)
        }
    }
}
