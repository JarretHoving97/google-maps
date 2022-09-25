import Capacitor
import FBSDKCoreKit

@objc(ExtendedFacebookPlugin)
public class ExtendedFacebookPlugin: CAPPlugin {
    @objc func updateSettings(_ call: CAPPluginCall) {
        let isAdvertiserTrackingEnabled = call.getBool("isAdvertiserTrackingEnabled")

        DispatchQueue.main.async {
            guard let isAdvertiserTrackingEnabled = isAdvertiserTrackingEnabled else {
                call.resolve()
                return
            }
            Settings.shared.isAdvertiserTrackingEnabled = isAdvertiserTrackingEnabled
            call.resolve()
        }
    }
}
