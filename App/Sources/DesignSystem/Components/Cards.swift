import SwiftUI

/// Row of gold stars.
struct StarRow: View {
    var count: Int = 5
    var size: CGFloat = 15
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<count, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundColor(PL.C.gold)
            }
        }
    }
}

/// A 5-star testimonial card.
struct ReviewCard: View {
    let text: String
    let author: String
    var body: some View {
        VStack(alignment: .leading, spacing: PL.S.sm) {
            StarRow(size: 13)
            Text(text)
                .font(PL.F.sans(15, .medium))
                .foregroundColor(PL.C.text)
                .fixedSize(horizontal: false, vertical: true)
            Text(author)
                .font(PL.F.sans(12, .bold))
                .foregroundColor(PL.C.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PL.S.lg)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }
}

/// Dark "reflect" card with an eyebrow, title and body (used on the right-place screen).
struct ReflectCard: View {
    let eyebrow: String
    let title: String
    let body_: String
    var body: some View {
        VStack(alignment: .leading, spacing: PL.S.sm) {
            Eyebrow(text: eyebrow, color: PL.C.gold)
            Text(title)
                .font(PL.F.serif(21, .regular))
                .foregroundColor(PL.C.textOnInk)
            Text(body_)
                .font(PL.F.sans(14, .regular))
                .foregroundColor(PL.C.textOnInkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PL.S.lg)
        .background(PL.C.ink)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
    }
}

/// Icon + title + subtitle row (community features).
struct FeatureRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: PL.S.lg) {
            ZStack {
                Circle().fill(PL.C.gold.opacity(0.16)).frame(width: 46, height: 46)
                Image(systemName: symbol)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundColor(PL.C.gold)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.text)
                Text(subtitle).font(PL.F.sans(14, .regular)).foregroundColor(PL.C.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

/// A saved prayer card. Compact = title + time (journal list); full = + prayer & scripture.
struct JournalEntryCard: View {
    let entry: JournalEntry
    var compact: Bool = false
    var showChevron: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: PL.S.sm) {
            HStack(spacing: PL.S.sm) {
                Circle().fill(PL.C.gold).frame(width: 8, height: 8)
                Text(entry.title)
                    .font(PL.F.serif(20, .regular)).foregroundColor(PL.C.text)
                Spacer(minLength: 0)
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(PL.C.textMuted)
                }
            }
            Text(entry.timeLabel)
                .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textMuted)
            if !compact {
                Text(entry.prayerText)
                    .font(PL.F.sans(15, .regular)).foregroundColor(PL.C.text)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, PL.S.xs)
                Eyebrow(text: entry.scriptureRef)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PL.S.lg)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }
}

/// Numbered step row (how-it-works).
struct NumberedStep: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(spacing: PL.S.lg) {
            ZStack {
                Circle().fill(PL.C.gold).frame(width: 30, height: 30)
                Text("\(number)").font(PL.F.sans(15, .bold)).foregroundColor(.white)
            }
            Text(text).font(PL.F.sans(17, .medium)).foregroundColor(PL.C.text)
            Spacer(minLength: 0)
        }
    }
}
