import SwiftUI

struct RootView: View {
    @ObservedObject private var app = AppModel.shared

    var body: some View {
        Group {
            if app.onboardingComplete {
                MainTabView()
            } else {
                OnboardingContainer()
            }
        }
    }
}
