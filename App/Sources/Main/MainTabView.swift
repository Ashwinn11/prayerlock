import SwiftUI

struct MainTabView: View {
    @State private var tab: PLTab = .home
    @State private var showPray = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home: HomeView(onPray: { showPray = true }, onMenu: { tab = .settings })
                case .bible: BibleView()
                case .journal: JournalView()
                case .settings: SettingsView()
                }
            }
            PLTabBar(selection: $tab)
        }
        .fullScreenCover(isPresented: $showPray) {
            PrayerSessionView(onClose: { showPray = false })
        }
        .preferredColorScheme(.light)
        .onAppear(perform: openPrayIfRequested)
        .task {
            // Make sure we have authorization (prompts only when undetermined),
            // then sync schedules to the user's enabled prayer times.
            let stm = ScreenTimeManager.shared
            if !stm.isAuthorized { await stm.requestAuthorization() }
            stm.reschedule(times: AppModel.shared.prayerTimes.filter { $0.enabled })
        }
    }

    /// The shield's "Open Prayer Lock" sets a flag; jump straight into the prayer flow.
    private func openPrayIfRequested() {
        if PL.defaults.bool(forKey: PL.Key.wantsToPray) {
            PL.defaults.set(false, forKey: PL.Key.wantsToPray)
            showPray = true
        }
    }
}
