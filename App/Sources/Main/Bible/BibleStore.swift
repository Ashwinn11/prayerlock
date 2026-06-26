import Foundation

struct BibleBook: Decodable, Identifiable {
    let name: String
    let testament: String   // "OT" / "NT"
    let chapters: [[String]]
    var id: String { name }
    var chapterCount: Int { chapters.count }
}

/// Loads the bundled KJV (66 books / 1189 chapters / 31,102 verses).
final class BibleStore: ObservableObject {
    static let shared = BibleStore()
    @Published private(set) var books: [BibleBook] = []

    init() { load() }

    private func load() {
        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        struct Root: Decodable { let books: [BibleBook] }
        if let root = try? JSONDecoder().decode(Root.self, from: data) {
            books = root.books
        }
    }

    var oldTestament: [BibleBook] { books.filter { $0.testament == "OT" } }
    var newTestament: [BibleBook] { books.filter { $0.testament == "NT" } }
}
