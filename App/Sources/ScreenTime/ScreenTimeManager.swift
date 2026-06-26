import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

/// App-side Screen Time coordinator: authorization, app selection (FamilyActivityPicker),
/// per-prayer-time scheduling, and manual lock/unlock.
@MainActor
final class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var selection: FamilyActivitySelection
    @Published var authorized: Bool = false

    private let center = DeviceActivityCenter()
    private let store = BlockedSelectionStore()

    init() {
        selection = store.load()
        authorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    var blockedCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            // user declined or unavailable (e.g. simulator)
        }
        authorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func saveSelection(_ s: FamilyActivitySelection) {
        selection = s
        store.save(s)
    }

    var isAuthorized: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    /// Schedule a monitored window per prayer time (start → end of day) so the monitor
    /// extension shields apps at each prayer time.
    /// No-ops until Family Controls is authorized (DeviceActivity calls throw otherwise).
    func reschedule(times: [PrayerTime]) {
        guard isAuthorized else { return }
        center.stopMonitoring()
        for (i, t) in times.enumerated() {
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: t.hour, minute: t.minute),
                intervalEnd: DateComponents(hour: 23, minute: 59),
                repeats: true)
            let name = DeviceActivityName("\(PL.activityPrefix)\(i)")
            try? center.startMonitoring(name, during: schedule)
        }
    }

    /// Immediately shield the selected apps from the app itself (used to test blocking
    /// without waiting for a schedule). Requires authorization.
    func lockNow() {
        guard isAuthorized else { return }
        ShieldController().lock()
    }
    func unlockNow() { ShieldController().unlock() }
    var isLocked: Bool { ShieldController().isLocked }

    /// Stop all monitoring, clear the shield, and clear the app selection.
    func clearAll() {
        if isAuthorized { center.stopMonitoring() }
        ShieldController().unlock()
        selection = FamilyActivitySelection()
        store.save(selection)
    }
}
