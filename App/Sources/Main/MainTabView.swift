import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: PLTab = .home
    @State private var showPray = false
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        ZStack(alignment: .bottom) {
            content
            PLTabBar(selected: $selectedTab)
                .padding(.horizontal, PL.S.xxl)
                .padding(.bottom, PL.S.sm)
        }
        .ignoresSafeArea(.keyboard)   // the floating bar shouldn't ride the keyboard
        .fullScreenCover(isPresented: $showPray) {
            PrayerSessionView(onClose: { showPray = false })
        }
        .preferredColorScheme(.light)
        .onAppear(perform: openPrayIfRequested)
        .task {
            let stm = ScreenTimeManager.shared
            if !stm.isAuthorized { await stm.requestAuthorization() }
            stm.reschedule(times: AppModel.shared.prayerTimes.filter { $0.enabled })
        }
    }

    /// Active tab content with a soft cross-tab transition (fade + slight rise).
    @ViewBuilder private var content: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(onPray: { showPray = true },
                         onMenu: { withPLAnimation(PL.Motion.bounce) { selectedTab = .settings } })
            case .bible:
                BibleView()
            case .journal:
                JournalView()
            case .settings:
                SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(reduce ? .opacity
                           : .opacity.combined(with: .offset(y: 10)).combined(with: .scale(scale: 0.995)))
        .id(selectedTab)
    }

    private func openPrayIfRequested() {
        if PL.defaults.bool(forKey: PL.Key.wantsToPray) {
            PL.defaults.set(false, forKey: PL.Key.wantsToPray)
            showPray = true
        }
    }
}
