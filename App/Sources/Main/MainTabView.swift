import SwiftUI

/// Placeholder — replaced by the full tabbed main app (Home/Bible/Journal/Settings).
struct MainTabView: View {
    var body: some View {
        ZStack {
            PL.C.cream.ignoresSafeArea()
            VStack(spacing: PL.S.lg) {
                GoldHeadline("Welcome home.", accents: ["home"], size: 32, alignment: .center)
                Text("Main app coming next.")
                    .font(.plBody).foregroundColor(PL.C.textMuted)
                Button("Reset onboarding") { AppModel.shared.onboardingComplete = false }
                    .font(.plButton).foregroundColor(PL.C.gold)
            }
            .padding()
        }
    }
}
