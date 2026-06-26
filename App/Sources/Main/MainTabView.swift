import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: PLTab = .home
    @State private var showPray = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(onPray: { showPray = true }, onMenu: { selectedTab = .settings })
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(PLTab.home)

            BibleView()
                .tabItem { Label("Bible", systemImage: "book.closed.fill") }
                .tag(PLTab.bible)

            JournalView()
                .tabItem { Label("Journal", systemImage: "checkmark.seal.fill") }
                .tag(PLTab.journal)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(PLTab.settings)
        }
        .tint(PL.C.gold)
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

    private func openPrayIfRequested() {
        if PL.defaults.bool(forKey: PL.Key.wantsToPray) {
            PL.defaults.set(false, forKey: PL.Key.wantsToPray)
            showPray = true
        }
    }
}
