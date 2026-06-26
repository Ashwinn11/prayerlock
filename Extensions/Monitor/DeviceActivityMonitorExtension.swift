import DeviceActivity
import ManagedSettings

/// Runs in the background. When a prayer window begins, shield the chosen apps;
/// the user clears the shield from the app by praying.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let shield = ShieldController()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // A prayer window started → lock the apps.
        shield.lock()
        PL.defaults.set(activity.rawValue, forKey: PL.Key.lastLockActivity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Window ended (end of day). Leave unlock decisions to the app.
    }
}
