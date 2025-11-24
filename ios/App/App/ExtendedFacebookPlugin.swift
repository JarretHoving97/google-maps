import Capacitor
import FacebookCore
import AppTrackingTransparency

enum TrackingAuthorizationStatus: String {
    case undetermined
    case restricted
    case denied
    case authorized
}

@objc(ExtendedFacebookPlugin)
public class ExtendedFacebookPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "ExtendedFacebook"

    public let jsName = "ExtendedFacebook"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "updateSettings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestTrackingAuthorization", returnType: CAPPluginReturnPromise)
    ]

    @objc func requestTrackingAuthorization(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            ATTrackingManager.requestTrackingAuthorization { status in
                let mappedStatus: TrackingAuthorizationStatus

                switch status {
                case .notDetermined:
                    mappedStatus = .undetermined
                case .restricted:
                    mappedStatus = .restricted
                case .denied:
                    mappedStatus = .denied
                case .authorized:
                    mappedStatus = .authorized
                @unknown default:
                    mappedStatus = .undetermined
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // For some unknown reason we when we retrieve `trackingAuthorizationStatus` right
                    // after (e.g. with Facebook Login) it has not updated yet to the new value.
                    // Therefor, while unreliable and ugly, we sleep a bit.

                    call.resolve([
                        "status": mappedStatus.rawValue
                    ])
                }
            }
        }
    }
    
    @available(*, deprecated, message: "This method is deprecated.")
    @objc func updateSettings(_ call: CAPPluginCall) {
        call.resolve([:])
    }
}
