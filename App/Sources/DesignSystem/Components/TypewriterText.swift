import SwiftUI

/// Types text out character-by-character (used for guided prayers).
struct TypewriterText: View {
    let text: String
    var font: Font = .plBody
    var color: Color = PL.C.text
    var charsPerSecond: Double = 45
    var alignment: TextAlignment = .center
    var onFinished: (() -> Void)? = nil

    @State private var count = 0
    @State private var timer: Timer?

    var body: some View {
        Text(String(text.prefix(count)))
            .font(font)
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
            .onAppear(perform: start)
            .onDisappear { timer?.invalidate() }
    }

    private func start() {
        count = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / charsPerSecond, repeats: true) { t in
            if count < text.count {
                count += 1
            } else {
                t.invalidate()
                onFinished?()
            }
        }
    }
}
