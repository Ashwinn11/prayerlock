import SwiftUI

struct PaywallScreen: View {
    @ObservedObject var ob: Onboarding
    @State private var plan: Plan = .yearly
    @State private var legal: LegalDoc?
    @State private var showRestore = false

    enum Plan { case yearly, weekly }

    var body: some View {
        ZStack {
            ScreenBackground(theme: .light)
                .plGodRays(source: .init(x: 0.5, y: 0.10), strength: 0.5)
            VStack(spacing: 0) {
                Spacer(minLength: PL.S.xl)
                VStack(spacing: PL.S.xl) {
                    FloatingIllustration(name: "hand-dove", symbol: "bird.fill", size: 120, glow: true)
                        .plReveal(0)
                    VStack(spacing: PL.S.md) {
                        GoldHeadline("From lukewarm to closer to God.", accents: ["closer to God"],
                                     size: 27, alignment: .center, foil: true)
                        PLSubtitle("Give God room to show up in your life.", alignment: .center)
                    }
                    .plReveal(1)
                    VStack(spacing: PL.S.xs) {
                        Eyebrow(text: "The #1 Prayer Habit App")
                        Text("Joined by 500,000+ people")
                            .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textMuted)
                    }
                    .plReveal(2)
                    VStack(spacing: PL.S.md) {
                        PlanOption(title: "Yearly", price: "$39.99 / year",
                                   subtitle: "3-day free trial • $0.77/week",
                                   badge: "BEST VALUE",
                                   selected: plan == .yearly) { select(.yearly) }
                            .plReveal(3)
                        PlanOption(title: "Weekly", price: "$9.99 / week",
                                   subtitle: "Billed weekly",
                                   selected: plan == .weekly) { select(.weekly) }
                            .plReveal(4)
                    }
                }
                .padding(.horizontal, PL.L.margin)
                .plContent()
                Spacer(minLength: PL.S.lg)
                footer
            }
        }
        .preferredColorScheme(.light)
        .sheet(item: $legal) { LegalView(doc: $0) }
        .alert("No purchases found", isPresented: $showRestore) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't find a previous purchase to restore.")
        }
    }

    private func select(_ p: Plan) {
        PL.Haptics.selection()
        withPLAnimation(PL.Motion.bounce) { plan = p }
    }

    private var footer: some View {
        VStack(spacing: PL.S.md) {
            PrimaryButton(title: "Start my 3-day free trial", shimmer: true, action: ob.next)
            Text("No commitment, cancel anytime. Charged after 3 days.")
                .font(PL.F.sans(12, .regular)).foregroundColor(PL.C.textMuted)
                .multilineTextAlignment(.center)
            HStack(spacing: PL.S.xl) {
                Button("Restore") { showRestore = true }
                Button("Terms") { legal = .terms }
                Button("Privacy") { legal = .privacy }
            }
            .font(PL.F.sans(12, .medium))
            .foregroundColor(PL.C.textMuted)
        }
        .padding(.horizontal, PL.L.margin)
        .padding(.top, PL.S.md)
        .padding(.bottom, PL.S.lg)
        .plContent()
    }
}

private struct PlanOption: View {
    let title: String
    let price: String
    let subtitle: String
    var badge: String? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PL.S.lg) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: PL.S.sm) {
                        Text(title).font(PL.F.sans(17, .bold)).foregroundColor(PL.C.text)
                        if let badge {
                            Text(badge)
                                .font(PL.F.sans(10, .bold)).tracking(0.6)
                                .foregroundColor(.white)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Capsule().fill(
                                    LinearGradient(colors: [PL.C.goldLight, PL.C.gold],
                                                   startPoint: .top, endPoint: .bottom)))
                        }
                    }
                    Text(subtitle).font(PL.F.sans(13, .regular)).foregroundColor(PL.C.textMuted)
                }
                Spacer()
                Text(price).font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.text)
            }
            .padding(PL.S.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .fill(PL.C.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                            .fill(PL.C.gold.opacity(selected ? 0.07 : 0))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .stroke(selected ? PL.C.gold : PL.C.stroke, lineWidth: selected ? 2 : 1)
            )
            .plGlow(PL.C.goldGlow, radius: 9, active: selected)
            .scaleEffect(selected ? 1.02 : 1)
        }
        .buttonStyle(.pressable(scale: 0.97, haptic: false))
        .animation(PL.Motion.bounce, value: selected)
    }
}
