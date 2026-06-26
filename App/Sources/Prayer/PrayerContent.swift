import Foundation

/// A guided prayer shown during the prayer session.
struct GuidedPrayer: Identifiable, Equatable {
    let id: String
    let title: String
    let cue: String        // breathing cue, e.g. "BREATHE"
    let body: String       // app-authored prayer (not scripture)
    let reference: String  // e.g. "PSALMS 46:10"
    var duration: Int = 60 // seconds

    /// Scripture text is ALWAYS resolved from the bundled KJV by `reference` — never hand-typed,
    /// so every verse the app shows is the real King James text (and can never drift or typo).
    var scripture: String { KJV.text(reference) ?? "" }
}

enum PrayerLibrary {

    /// Verse of the day — one verse per calendar day (stable all day, rotates daily) so the
    /// onboarding screen and the Bible tab always show the same verse. Only the *pick* rotates;
    /// the text itself comes from KJV.
    static var verseOfDay: (text: String, reference: String) {
        guard !dailyVerseRefs.isEmpty else { return ("", "") }
        let day = Int(Date().timeIntervalSince1970 / 86_400)
        let ref = dailyVerseRefs[((day % dailyVerseRefs.count) + dailyVerseRefs.count) % dailyVerseRefs.count]
        return (KJV.text(ref) ?? "", ref)
    }

    /// Well-known, encouraging KJV verses — REFERENCES ONLY. The displayed text is looked up from
    /// kjv.json, so this stays real KJV no matter how it's edited. Safe to add to / reorder.
    static let dailyVerseRefs: [String] = [
        "PSALMS 23:1", "JOHN 3:16", "PHILIPPIANS 4:13", "PHILIPPIANS 4:6", "JEREMIAH 29:11",
        "PROVERBS 3:5", "ISAIAH 41:10", "MATTHEW 11:28", "ROMANS 8:28", "JOSHUA 1:9",
        "PSALMS 46:10", "PSALMS 118:24", "1 PETER 5:7", "PSALMS 27:1", "ISAIAH 40:31",
        "MATTHEW 6:33", "JOHN 14:27", "PSALMS 34:8", "PSALMS 37:4", "ROMANS 12:2",
        "2 CORINTHIANS 5:17", "HEBREWS 11:1", "JAMES 1:5", "PSALMS 19:14", "PSALMS 51:10",
        "MICAH 6:8", "ZEPHANIAH 3:17", "PSALMS 145:18", "DEUTERONOMY 31:6", "PSALMS 16:11",
        "COLOSSIANS 3:23", "PSALMS 91:1", "ISAIAH 26:3", "ROMANS 15:13", "PSALMS 56:3",
        "JOHN 8:12", "PSALMS 121:2", "PROVERBS 3:6", "1 JOHN 4:19", "PSALMS 28:7",
    ]

    /// Guided prayers. Each carries only a scripture *reference*; the verse text is resolved from
    /// KJV via `GuidedPrayer.scripture`. The prayer `body` is app-authored devotional text.
    static let all: [GuidedPrayer] = [
        GuidedPrayer(
            id: "be-still", title: "Be Still", cue: "BREATHE",
            body: "Lord, my mind is racing and my body feels tense, so I pause to remember that You are God and I am not. Quiet the noise inside me and help me be still long enough to know that You are in control. I don't have to fix everything; I only have to trust You.",
            reference: "PSALMS 46:10"),
        GuidedPrayer(
            id: "thirsty", title: "Thirsty For You", cue: "BREATHE",
            body: "Lord, my soul feels dry and worn, and I am thirsty for more of You. Refresh the parched places in me, and satisfy the deep longing only You can fill.",
            reference: "PSALMS 42:1"),
        GuidedPrayer(
            id: "draw-near", title: "Draw Me Near", cue: "BREATHE",
            body: "Lord, my heart feels distant and I long to be close to You again. Draw me near as I turn toward You, and let me feel Your nearness in this quiet moment.",
            reference: "JAMES 4:8"),
        GuidedPrayer(
            id: "cast-care", title: "Cast Your Care", cue: "EXHALE",
            body: "Father, I am carrying worries too heavy for me. I lay them down before You now, trusting that You see me and care for me. Trade my anxiety for Your peace.",
            reference: "1 PETER 5:7"),
        GuidedPrayer(
            id: "renew", title: "Renew My Mind", cue: "BREATHE",
            body: "Lord, the world is loud and my attention is scattered. Renew my mind and set my thoughts on what is true and good, that I might know Your will today.",
            reference: "ROMANS 12:2"),
        GuidedPrayer(
            id: "grateful", title: "A Grateful Heart", cue: "BREATHE",
            body: "Thank You, Lord, for this breath and this day. Before I reach for anything else, I reach for You. Let gratitude reorder my heart and lead me into Your presence.",
            reference: "PSALMS 118:24"),
    ]

    static func byID(_ id: String) -> GuidedPrayer { all.first { $0.id == id } ?? all[0] }

    /// Journal thumbnail illustration for a given prayer.
    static func illustration(for id: String) -> String {
        switch id {
        case "be-still": return "praying-woman"
        case "thirsty": return "chalice"
        case "draw-near": return "bible"
        case "cast-care": return "hands-cross"
        case "renew": return "cross-shroud"
        case "grateful": return "church"
        default: return "dove"
        }
    }

    /// Build a saveable journal entry from a prayer.
    static func entry(for prayer: GuidedPrayer, reflection: String = "") -> JournalEntry {
        JournalEntry(title: prayer.title, prayerText: prayer.body,
                     scriptureText: prayer.scripture, scriptureRef: prayer.reference,
                     reflection: reflection, illustration: illustration(for: prayer.id))
    }

    /// Core selection: pick a prayer from the two emoji check-ins (0...4 each).
    /// A distant relationship overrides; otherwise feeling drives the choice.
    static func forMoods(feeling: Int, relationship: Int) -> GuidedPrayer {
        if relationship <= 1 { return byID("draw-near") }
        switch feeling {
        case 0: return byID("cast-care")   // awful → anxiety
        case 1: return byID("thirsty")     // low → dry
        case 2: return byID("be-still")    // okay
        case 3: return byID("renew")       // good
        default: return byID("grateful")   // great
        }
    }

}

// MARK: - KJV (King James Version) — single source of truth for all scripture text

/// Resolves Bible references to their KJV text from the bundled `kjv.json`
/// (`{ books: [{ name, chapters: [[verse, …], …] }] }`). No verse is ever hand-typed in code:
/// the app stores references, and the words come from here.
enum KJV {
    private struct File: Decodable {
        struct Book: Decodable { let name: String; let chapters: [[String]] }
        let books: [Book]
    }

    /// Loaded once, lazily, and indexed by lowercased book name → chapters → verses.
    private static let byBook: [String: [[String]]] = {
        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data)
        else { return [:] }
        return Dictionary(uniqueKeysWithValues: file.books.map { ($0.name.lowercased(), $0.chapters) })
    }()

    /// Resolve a reference like "PSALMS 46:10" or "1 PETER 5:7" to its KJV verse text.
    /// Book matching is case-insensitive; returns nil for an unknown/out-of-range reference.
    static func text(_ reference: String) -> String? {
        let parts = reference.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        let cv = parts[parts.count - 1].split(separator: ":")
        guard cv.count == 2, let chapter = Int(cv[0]), let verse = Int(cv[1]) else { return nil }
        let book = parts.dropLast().joined(separator: " ").lowercased()
        guard let chapters = byBook[book],
              chapter >= 1, chapter <= chapters.count,
              verse >= 1, verse <= chapters[chapter - 1].count else { return nil }
        return chapters[chapter - 1][verse - 1]
    }
}
