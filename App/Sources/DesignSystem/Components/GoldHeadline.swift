import SwiftUI

/// Serif headline with one or more gold accent phrases — the app's signature title style.
/// Example: GoldHeadline("Once you pray, your apps unlock.", accents: ["pray"])
struct GoldHeadline: View {
    let text: String
    var accents: [String] = []
    var size: CGFloat = 32
    var weight: PL.F.SerifWeight = .regular
    var base: Color = PL.C.text
    var accent: Color = PL.C.gold
    var alignment: TextAlignment = .leading

    var body: some View {
        Text(Self.attributed(text, accents: accents, font: PL.F.serif(size, weight),
                             base: base, accent: accent))
            .multilineTextAlignment(alignment)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
    }

    static func attributed(_ text: String, accents: [String], font: Font,
                           base: Color, accent: Color) -> AttributedString {
        var attr = AttributedString(text)
        attr.font = font
        attr.foregroundColor = base
        for phrase in accents where !phrase.isEmpty {
            var search = attr.startIndex
            while let range = attr[search...].range(of: phrase) {
                attr[range].foregroundColor = accent
                search = range.upperBound
            }
        }
        return attr
    }
}

/// Muted sans subtitle used under most headlines.
struct PLSubtitle: View {
    let text: String
    var alignment: TextAlignment = .leading
    var color: Color = PL.C.textMuted
    init(_ text: String, alignment: TextAlignment = .leading, color: Color = PL.C.textMuted) {
        self.text = text; self.alignment = alignment; self.color = color
    }
    var body: some View {
        Text(text)
            .font(.plSubtitle)
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
    }
}
