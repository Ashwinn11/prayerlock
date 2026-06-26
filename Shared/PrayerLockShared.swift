import Foundation
import FamilyControls
import ManagedSettings

/// FamilyControls/ManagedSettings additions to the shared `PL` namespace
/// (base namespace is in PLNamespace.swift).
extension PL {
    /// Named ManagedSettingsStore so the app (to unlock) and the monitor extension
    /// (to lock) write to the same shield store.
    static let storeName = ManagedSettingsStore.Name("PrayerLockShield")
}

/// Persists the user's chosen apps/categories to block, shared across processes.
public struct BlockedSelectionStore {
    public init() {}

    public func save(_ selection: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(selection) {
            PL.defaults.set(data, forKey: PL.Key.blockedSelection)
        }
    }

    public func load() -> FamilyActivitySelection {
        guard let data = PL.defaults.data(forKey: PL.Key.blockedSelection),
              let sel = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return sel
    }

    public var count: Int {
        let s = load()
        return s.applicationTokens.count + s.categoryTokens.count + s.webDomainTokens.count
    }
}

/// Applies / clears the shield on the shared ManagedSettingsStore.
public struct ShieldController {
    private let store = ManagedSettingsStore(named: PL.storeName)
    public init() {}

    /// Lock: shield the currently-saved selection.
    public func lock() {
        let selection = BlockedSelectionStore().load()
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        PL.defaults.set(true, forKey: PL.Key.isLocked)
    }

    /// Unlock: remove all shields (called after the user prays).
    public func unlock(untilEndOfDay: Bool = true) {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        PL.defaults.set(false, forKey: PL.Key.isLocked)
        if untilEndOfDay {
            let cal = Calendar.current
            let end = cal.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
            PL.defaults.set(end.timeIntervalSince1970, forKey: PL.Key.unlockedUntil)
        }
    }

    public var isLocked: Bool { PL.defaults.bool(forKey: PL.Key.isLocked) }
}
