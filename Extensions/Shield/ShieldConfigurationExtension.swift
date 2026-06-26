import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Custom appearance for the lock screen shown over blocked apps:
/// "Time to pray" with an "Open Prayer Lock" primary button.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private var prayerShield: ShieldConfiguration {
        let cream = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        let charcoal = UIColor(red: 0.227, green: 0.208, blue: 0.176, alpha: 1.0)
        let gold = UIColor(red: 0.71, green: 0.51, blue: 0.18, alpha: 1.0)
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThinMaterial,
            backgroundColor: cream,
            icon: UIImage(named: "ShieldIcon"),
            title: ShieldConfiguration.Label(text: "Time to pray", color: charcoal),
            subtitle: ShieldConfiguration.Label(
                text: "Pause, pray, and your apps unlock for the rest of today.",
                color: charcoal.withAlphaComponent(0.7)),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Open Prayer Lock", color: .white),
            primaryButtonBackgroundColor: charcoal,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: gold)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        prayerShield
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        prayerShield
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        prayerShield
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        prayerShield
    }
}
