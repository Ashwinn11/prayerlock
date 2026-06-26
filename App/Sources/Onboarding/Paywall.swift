import SwiftUI

struct PaywallScreen: View {
    @ObservedObject var ob: Onboarding
    @State private var plan: Plan = .yearly
    @State private var legal: LegalDoc?
    @State private var showRestore = false

    enum Plan { case yearly, weekly }

    var body: some View {
        ZStack {
            PL.C.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PL.S.xl) {
                        IllustrationSlot(name: "hand-dove", fallbackSymbol: "bird.fill", size: 120)
                        VStack(spacing: PL.S.md) {
                            GoldHeadline("From lukewarm to closer to God.", accents: ["closer to God"],
                                         size: 27, alignment: .center)
                            PLSubtitle("Give God room to show up in your life.", alignment: .center)
                        }
                        VStack(spacing: PL.S.xs) {
                            Eyebrow(text: "The #1 Prayer Habit App")
                            Text("Joined by 500,000+ people")
                                .font(PL.F.sans(13, .medium)).foregroundColor(PL.C.textMuted)
                        }
                        VStack(spacing: PL.S.md) {
                            PlanOption(title: "Yearly", price: "$39.99 / year",
                                       subtitle: "3-day free trial • $0.77/week",
                                       selected: plan == .yearly) { plan = .yearly }
                            PlanOption(title: "Weekly", price: "$9.99 / week",
                                       subtitle: "Billed weekly",
                                       selected: plan == .weekly) { plan = .weekly }
                        }
                    }
                    .padding(.top, PL.S.xxl)
                    .padding(.horizontal, PL.L.margin)
                    .plContent()
                }
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

    private var footer: some View {
        VStack(spacing: PL.S.md) {
            PrimaryButton(title: "Start my 3-day free trial", action: ob.next)
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
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PL.S.lg) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(PL.F.sans(17, .bold)).foregroundColor(PL.C.text)
                    Text(subtitle).font(PL.F.sans(13, .regular)).foregroundColor(PL.C.textMuted)
                }
                Spacer()
                Text(price).font(PL.F.sans(16, .semibold)).foregroundColor(PL.C.text)
            }
            .padding(PL.S.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PL.C.card)
            .clipShape(RoundedRectangle(cornerRadius: PL.R.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PL.R.card, style: .continuous)
                    .stroke(selected ? PL.C.gold : PL.C.stroke, lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
