import Foundation

/// Core app namespace. Framework-free so it resolves everywhere (app + extensions,
/// and editor analysis on macOS). FamilyControls/ManagedSettings additions live in
/// PrayerLockShared.swift; design-system additions (colors/fonts/metrics) live in App.
public enum PL {
    /// App Group shared between the app + monitor/shield/shieldaction extensions.
    public static let appGroup = "group.prayer.lock.app"

    /// Prefix for the per-prayer-time DeviceActivity schedules.
    public static let activityPrefix = "prayer.window."

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    enum Key {
        static let blockedSelection = "blockedSelection"      // Data (encoded FamilyActivitySelection)
        static let isLocked = "isLocked"                       // Bool — apps currently shielded
        static let unlockedUntil = "unlockedUntil"             // Double (timeIntervalSince1970)
        static let lastLockActivity = "lastLockActivity"       // String
        static let wantsToPray = "wantsToPray"                 // Bool — set by shield action
    }
}
