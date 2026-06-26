import SwiftUI

struct BibleView: View {
    @ObservedObject var store = BibleStore.shared

    private let cols = [GridItem(.flexible(), spacing: PL.S.md),
                        GridItem(.flexible(), spacing: PL.S.md)]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: PL.S.xl) {
                    Text("Bible")
                        .font(PL.F.serif(34, .regular)).foregroundColor(PL.C.text)
                    verseOfDayCard
                    section("Old Testament", books: store.oldTestament)
                    section("New Testament", books: store.newTestament)
                }
                .padding(.horizontal, PL.L.margin)
                .padding(.top, PL.S.sm)
                .padding(.bottom, 110)
            }
            .background(PL.C.cream.ignoresSafeArea())
        }
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
        .background(PL.C.ink)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
    }

    private func section(_ title: String, books: [BibleBook]) -> some View {
        VStack(alignment: .leading, spacing: PL.S.md) {
            Eyebrow(text: title)
            LazyVGrid(columns: cols, spacing: PL.S.md) {
                ForEach(books) { book in
                    NavigationLink { ChapterListView(book: book) } label: { bookCard(book) }
                        .buttonStyle(.plain)
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

struct ChapterListView: View {
    let book: BibleBook
    private let cols = Array(repeating: GridItem(.flexible(), spacing: PL.S.md), count: 4)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: cols, spacing: PL.S.md) {
                ForEach(1...book.chapterCount, id: \.self) { ch in
                    NavigationLink { ReaderView(book: book, chapter: ch) } label: {
                        Text("\(ch)")
                            .font(PL.F.serif(18, .regular)).foregroundColor(PL.C.text)
                            .frame(maxWidth: .infinity).frame(height: 60)
                            .background(PL.C.card)
                            .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
                            .plCardStroke()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(PL.L.margin)
            .padding(.bottom, 110)
        }
        .background(PL.C.cream.ignoresSafeArea())
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReaderView: View {
    let book: BibleBook
    let chapter: Int

    private var verses: [String] { book.chapters[chapter - 1] }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.lg) {
                Text("\(book.name) \(chapter)")
                    .font(PL.F.serif(28, .regular)).foregroundColor(PL.C.text)
                    .padding(.bottom, PL.S.xs)
                ForEach(Array(verses.enumerated()), id: \.offset) { idx, verse in
                    (Text("\(idx + 1) ")
                        .font(PL.F.sans(12, .bold)).foregroundColor(PL.C.gold)
                        + Text(verse)
                        .font(PL.F.serif(18, .regular)).foregroundColor(PL.C.text))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
        }
        .background(PL.C.cream.ignoresSafeArea())
        .navigationTitle("\(book.name) \(chapter)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
