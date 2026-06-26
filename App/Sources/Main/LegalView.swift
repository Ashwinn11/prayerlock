import SwiftUI

enum LegalDoc: String, Identifiable {
    case privacy = "Privacy Policy"
    case terms = "Terms of Use"
    var id: String { rawValue }

    var content: String {
        switch self {
        case .privacy:
            return """
            Last updated: 2026

            Prayer Lock is built to help you put God first. We collect as little as possible.

            What we store
            Your name, prayer times, journal entries, and progress are stored on your device (and in your private iCloud-backed app group). We do not sell your data.

            Screen Time
            Prayer Lock uses Apple's Family Controls / Screen Time framework to shield the apps you choose. Your app selection never leaves your device — Apple provides only opaque tokens, which we cannot read or transmit.

            Notifications
            With your permission, we send a daily reminder and a prompt when it's time to pray. You can turn these off at any time in Settings.

            Analytics
            We may collect anonymous, aggregate usage to improve the app. This never includes your journal entries or scripture activity.

            Your choices
            You can delete all of your data at any time from Settings → Delete all data. This removes your journal, streak, and selections from this device.

            Contact
            Questions? Reach out at support@prayerlock.app.
            """
        case .terms:
            return """
            Last updated: 2026

            Welcome to Prayer Lock. By using the app you agree to these terms.

            The service
            Prayer Lock helps you build a daily prayer habit by shielding selected apps until you pray. It is a tool to support your walk with God — not a substitute for it.

            Subscriptions
            Some features may require a subscription. Pricing and trial terms are shown before you purchase. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the period, managed through your Apple ID.

            Acceptable use
            Use Prayer Lock for personal, lawful purposes. Don't attempt to disrupt the Screen Time protections for others.

            Scripture
            Scripture quotations are from the King James Version (KJV), which is in the public domain.

            Disclaimer
            Prayer Lock is provided "as is." We are not liable for missed notifications or any reliance on the app's shielding.

            Changes
            We may update these terms; continued use means you accept the changes.

            Contact
            Questions? Reach out at support@prayerlock.app.
            """
        }
    }
}

struct LegalView: View {
    let doc: LegalDoc
    @Environment(\.dismiss) private var dismiss

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
                    Text(doc.rawValue)
                        .font(PL.F.serif(30, .regular)).foregroundColor(PL.C.text)
                    Text(doc.content)
                        .font(.plBody).foregroundColor(PL.C.text).lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, PL.L.margin)
                .padding(.vertical, PL.S.xl)
            }
        }
        .preferredColorScheme(.light)
    }
}
