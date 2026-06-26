import ManagedSettings

/// Handles taps on the custom shield buttons.
/// Note: iOS does not allow a shield action to directly launch the containing app,
/// so "Open Prayer Lock" records intent and closes to the Home Screen (where the
/// daily notification / app icon takes the user into the prayer flow).
class ShieldActionExtension: ShieldActionDelegate {

    private func respond(_ action: ShieldAction,
                         _ completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            PL.defaults.set(true, forKey: PL.Key.wantsToPray)
            completionHandler(.close)
        case .secondaryButtonPressed,
             .firstSecondarySubmenuItemPressed,
             .secondSecondarySubmenuItemPressed,
             .thirdSecondarySubmenuItemPressed:
            completionHandler(.defer)
        @unknown default:
            completionHandler(.none)
        }
    }

    override func handle(action: ShieldAction, for application: ApplicationToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, completionHandler)
    }
}
