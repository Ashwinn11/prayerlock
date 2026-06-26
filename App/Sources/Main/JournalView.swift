import SwiftUI

struct JournalView: View {
    @ObservedObject var app = AppModel.shared
    @State private var expanded = false
    @State private var selected: JournalEntry?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PL.S.lg) {
                Text("Journal")
                    .font(PL.F.serif(34, .regular)).foregroundColor(PL.C.text)
                journeyCard
                if app.journal.isEmpty {
                    emptyState
                } else {
                    ForEach(app.journal) { entry in
                        Button { selected = entry } label: { entryRow(entry) }
                            .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, PL.L.margin)
            .padding(.top, PL.S.sm)
            .padding(.bottom, 110)
            .plContent()
        }
        .background(PL.C.cream.ignoresSafeArea())
        .sheet(item: $selected) { entry in
            JournalEntryDetail(entry: entry)
        }
    }

    private var journeyCard: some View {
        VStack(alignment: .leading, spacing: PL.S.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Prayer journey")
                        .font(PL.F.serif(20, .regular)).foregroundColor(PL.C.textOnInk)
                    Text("\(app.streak)-day streak")
                        .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textOnInkMuted)
                }
                Spacer()
                Button { withAnimation(.snappy) { expanded.toggle() } } label: {
                    HStack(spacing: 3) {
                        Text(expanded ? "Less" : "90 days")
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(PL.F.sans(14, .semibold)).foregroundColor(PL.C.gold)
                }
                .buttonStyle(.plain)
            }
            HeatmapGrid(total: expanded ? 90 : 7,
                        columns: expanded ? 9 : 7,
                        done: app.streak, fillFromEnd: false)
        }
        .padding(PL.S.xl)
        .background(PL.C.ink)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.bigCard, style: .continuous))
    }

    private func entryRow(_ entry: JournalEntry) -> some View {
        HStack(spacing: PL.S.lg) {
            IllustrationSlot(name: entry.illustration ?? "dove",
                             fallbackSymbol: "leaf.fill", size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title).font(PL.F.serif(20, .regular)).foregroundColor(PL.C.text)
                Text(entry.timeLabel).font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(PL.S.lg)
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }

    private var emptyState: some View {
        VStack(spacing: PL.S.md) {
            IllustrationSlot(name: "dove", fallbackSymbol: "leaf.fill", size: 90)
            Text("Your prayers will appear here.")
                .font(.plSubtitle).foregroundColor(PL.C.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, PL.S.xxxl)
    }
}

struct JournalEntryDetail: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var app = AppModel.shared
    @State private var reflection: String

    init(entry: JournalEntry) {
        self.entry = entry
        _reflection = State(initialValue: entry.reflection)
    }

    var body: some View {
        ZStack {
            PL.C.cream.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: PL.S.lg) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold)).foregroundColor(PL.C.text)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(PL.C.stroke, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    Text(entry.title)
                        .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.text)
                    Text(entry.fullDateLabel)
                        .font(.plSubtitle).foregroundColor(PL.C.textMuted)
                    Text(entry.prayerText)
                        .font(.plBody).foregroundColor(PL.C.text).lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    ScriptureDarkCard(text: entry.scriptureText, reference: entry.scriptureRef,
                                      italic: true, textColor: PL.C.gold, refColor: PL.C.textOnInk)
                    Eyebrow(text: "Your Reflection").padding(.top, PL.S.sm)
                    ReflectionEditor(text: $reflection)
                    PrimaryButton(title: "Save") {
                        if let i = app.journal.firstIndex(where: { $0.id == entry.id }) {
                            app.journal[i].reflection = reflection
                        }
                        dismiss()
                    }
                    .padding(.top, PL.S.sm)
                }
                .padding(.horizontal, PL.L.margin)
                .padding(.vertical, PL.S.xl)
                .plContent()
            }
        }
    }
}

/// Cream text editor with italic placeholder (reflections).
struct ReflectionEditor: View {
    @Binding var text: String
    var placeholder: String = "Write a thought, a thanks, or a hope…"
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(PL.F.serifItalic(16)).foregroundColor(PL.C.textMuted)
                    .padding(.horizontal, PL.S.lg).padding(.vertical, PL.S.lg + 2)
            }
            TextEditor(text: $text)
                .font(.plBody).foregroundColor(PL.C.text)
                .scrollContentBackground(.hidden)
                .padding(PL.S.md)
                .frame(height: 150)
        }
        .background(PL.C.card)
        .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
        .plCardStroke()
    }
}
