import Foundation

/// A guided prayer shown during the prayer session.
struct GuidedPrayer: Identifiable, Equatable {
    let id: String
    let title: String
    let cue: String        // breathing cue, e.g. "BREATHE"
    let body: String
    let scripture: String
    let reference: String
    var duration: Int = 60 // seconds
}

enum PrayerLibrary {
    static let verseOfDay = (
        text: "He hath shewed thee, O man, what is good; and what doth the LORD require of thee, but to do justly, and to love mercy, and to walk humbly with thy God?",
        reference: "MICAH 6:8"
    )

    static let all: [GuidedPrayer] = [
        GuidedPrayer(
            id: "be-still", title: "Be Still", cue: "BREATHE",
            body: "Lord, my mind is racing and my body feels tense, so I pause to remember that You are God and I am not. Quiet the noise inside me and help me be still long enough to know that You are in control. I don't have to fix everything; I only have to trust You.",
            scripture: "Be still, and know that I am God: I will be exalted among the heathen, I will be exalted in the earth.",
            reference: "PSALMS 46:10"),
        GuidedPrayer(
            id: "thirsty", title: "Thirsty For You", cue: "BREATHE",
            body: "Lord, my soul feels dry and worn, and I am thirsty for more of You. Refresh the parched places in me, and satisfy the deep longing only You can fill.",
            scripture: "As the hart panteth after the water brooks, so panteth my soul after thee, O God.",
            reference: "PSALMS 42:1"),
        GuidedPrayer(
            id: "draw-near", title: "Draw Me Near", cue: "BREATHE",
            body: "Lord, my heart feels distant and I long to be close to You again. Draw me near as I turn toward You, and let me feel Your nearness in this quiet moment.",
            scripture: "Draw nigh to God, and he will draw nigh to you. Cleanse your hands, ye sinners; and purify your hearts, ye double minded.",
            reference: "JAMES 4:8"),
        GuidedPrayer(
            id: "cast-care", title: "Cast Your Care", cue: "EXHALE",
            body: "Father, I am carrying worries too heavy for me. I lay them down before You now, trusting that You see me and care for me. Trade my anxiety for Your peace.",
            scripture: "Casting all your care upon him; for he careth for you.",
            reference: "1 PETER 5:7"),
        GuidedPrayer(
            id: "renew", title: "Renew My Mind", cue: "BREATHE",
            body: "Lord, the world is loud and my attention is scattered. Renew my mind and set my thoughts on what is true and good, that I might know Your will today.",
            scripture: "And be not conformed to this world: but be ye transformed by the renewing of your mind.",
            reference: "ROMANS 12:2"),
        GuidedPrayer(
            id: "grateful", title: "A Grateful Heart", cue: "BREATHE",
            body: "Thank You, Lord, for this breath and this day. Before I reach for anything else, I reach for You. Let gratitude reorder my heart and lead me into Your presence.",
            scripture: "This is the day which the LORD hath made; we will rejoice and be glad in it.",
            reference: "PSALMS 118:24"),
    ]

    static func byID(_ id: String) -> GuidedPrayer { all.first { $0.id == id } ?? all[0] }

    /// Pick a prayer that fits how the user said they feel.
    static func forMood(_ mood: String) -> GuidedPrayer {
        let m = mood.lowercased()
        if m.contains("anx") || m.contains("worr") || m.contains("stress") { return byID("cast-care") }
        if m.contains("dry") || m.contains("empty") || m.contains("tired") { return byID("thirsty") }
        if m.contains("distant") || m.contains("far") || m.contains("lost") { return byID("draw-near") }
        if m.contains("grate") || m.contains("thank") || m.contains("good") || m.contains("bless") { return byID("grateful") }
        if m.contains("scatter") || m.contains("distract") || m.contains("busy") { return byID("renew") }
        return byID("be-still")
    }
}
