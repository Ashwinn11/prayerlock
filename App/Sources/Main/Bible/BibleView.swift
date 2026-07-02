import SwiftUI

private enum BibleNav {
    case list
    case chapters(BibleBook)
    case reader(BibleBook, Int)

    var depth: Int {
        switch self {
        case .list: return 0
        case .chapters: return 1
        case .reader: return 2
        }
    }
}

struct BibleView: View {
    @ObservedObject var store = BibleStore.shared
    @State private var nav: BibleNav = .list
    @State private var forward = true
    @Environment(\.accessibilityReduceMotion) private var reduce

    private let bookCols = [GridItem(.flexible(), spacing: PL.S.md),
                             GridItem(.flexible(), spacing: PL.S.md)]
    private let chapterCols = Array(repeating: GridItem(.flexible(), spacing: PL.S.md), count: 4)

    var body: some View {
        ZStack {
            Group {
                switch nav {
                case .list:
                    listView
                case .chapters(let book):
                    chapterView(book)
                case .reader(let book, let ch):
                    readerView(book, ch)
                }
            }
            .id(nav.depth)
            .transition(navTransition)
        }
        .plScreen()
    }

    /// Directional push: deeper screens slide in from the right, back from the left.
    private var navTransition: AnyTransition {
        if reduce { return .opacity }
        return .asymmetric(
            insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity))
    }

    private func go(_ to: BibleNav) {
        PL.Haptics.light()
        forward = to.depth > nav.depth
        withPLAnimation(PL.Motion.screen) { nav = to }
    }

    // MARK: – Book list

    private var listView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                Text("Bible")
                    .font(PL.F.serif(34, .regular)).foregroundColor(PL.C.text)
                    .plReveal(0)
                verseOfDayCard
                    .plReveal(1)
                section("Old Testament", books: store.oldTestament)
                section("New Testament", books: store.newTestament)
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
            .plContent()
        }
    }

    // MARK: – Chapter list

    private func chapterView(_ book: BibleBook) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.xl) {
                backButton { go(.list) }
                Text(book.name)
                    .font(PL.F.serif(28, .regular)).foregroundColor(PL.C.text)
                LazyVGrid(columns: chapterCols, spacing: PL.S.md) {
                    ForEach(1...book.chapterCount, id: \.self) { ch in
                        Button { go(.reader(book, ch)) } label: {
                            Text("\(ch)")
                                .font(PL.F.serif(18, .regular)).foregroundColor(PL.C.text)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(PL.C.card)
                                .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
                                .plCardStroke()
                        }
                        .buttonStyle(.pressable(scale: 0.94, haptic: false))
                    }
                }
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
            .plContent()
        }
    }

    // MARK: – Reader

    private func readerView(_ book: BibleBook, _ chapter: Int) -> some View {
        let verses = book.chapters[chapter - 1]
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.lg) {
                backButton { go(.chapters(book)) }
                Text("\(book.name) \(chapter)")
                    .font(PL.F.serif(28, .regular)).foregroundColor(PL.C.text)
                    .padding(.bottom, PL.S.xs)
                ForEach(Array(verses.enumerated()), id: \.offset) { idx, verse in
                    (Text("\(idx + 1) ")
                        .font(PL.F.sans(12, .bold)).foregroundColor(PL.C.gold)
                        + Text(verse)
                        .font(PL.F.serif(18, .regular)).foregroundColor(PL.C.text))
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollTransition(.animated(PL.Motion.gentle)) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.25)
                                .offset(y: phase == .bottomTrailing ? 14 : 0)
                        }
                }
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
            .plContent()
        }
    }

    // MARK: – Shared components

    private func backButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(PL.C.text)
                .frame(width: PL.L.backButton, height: PL.L.backButton)
                .overlay(Circle().stroke(PL.C.text.opacity(0.22), lineWidth: 1.2))
        }
        .buttonStyle(.pressable)
    }

    private var verseOfDayCard: some View {
        VStack(alignment: .leading, spacing: PL.S.md) {
            Eyebrow(text: "Verse of the Day")
            Text(PrayerLibrary.verseOfDay.text)
                .font(PL.F.serif(19, .regular)).foregroundColor(PL.C.textOnInk)
                .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
            Eyebrow(text: PrayerLibrary.verseOfDay.reference)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PL.S.xl)
        .background(
            RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous)
                .fill(PL.C.ink)
                .overlay(
                    RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous)
                        .fill(RadialGradient(colors: [PL.C.inkGlow.opacity(0.8), .clear],
                                             center: .init(x: 0.2, y: 0.0),
                                             startRadius: 0, endRadius: 280))
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
        .shadow(color: PL.C.shadowAmbient, radius: 18, y: 9)
        .shadow(color: PL.C.shadowKey, radius: 5, y: 2)
    }

    private func section(_ title: String, books: [BibleBook]) -> some View {
        VStack(alignment: .leading, spacing: PL.S.md) {
            Eyebrow(text: title)
            LazyVGrid(columns: bookCols, spacing: PL.S.md) {
                ForEach(books) { book in
                    Button { go(.chapters(book)) } label: { bookCard(book) }
                        .buttonStyle(.pressable(scale: 0.95, haptic: false))
                }
            }
        }
    }

    private func bookCard(_ book: BibleBook) -> some View {
        HStack {
            Text(book.name).font(PL.F.serif(17, .regular)).foregroundColor(PL.C.text)
            Spacer()
            Text("\(book.chapterCount)")
                .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textMuted)
        }
        .padding(.horizontal, PL.S.lg)
        .frame(height: 56)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }
}
