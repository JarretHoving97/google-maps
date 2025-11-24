import Foundation
import FacebookCore
import FacebookLogin
import Capacitor
import CapacitorCommunityGenericOauth2
import AppTrackingTransparency

@objc class FacebookOAuth2Handler: NSObject, OAuth2CustomHandler {

    required override init() {
    }

    func getAccessToken(
        viewController: UIViewController,
        call: CAPPluginCall,
        success: @escaping (String) -> Void,
        cancelled: @escaping () -> Void,
        failure: @escaping (Error) -> Void
    ) {
        let tracking = ATTrackingManager.trackingAuthorizationStatus == .authorized ? LoginTracking.enabled : LoginTracking.limited

        let config = LoginConfiguration(
            permissions: ["public_profile", "email"],
            tracking: tracking,
        )

        guard let config else {
            return
        }

        DispatchQueue.main.async {
            LoginManager().logIn(viewController: viewController, configuration: config) { result in
                switch result {
                case .success(granted: _, declined: _, token: let token?):
                    // Standard login
                    return success(token.tokenString)

                case .success(granted: _, declined: _, token: nil):
                    // Limited login
                    if let token = AuthenticationToken.current {
                        return success(token.tokenString)
                    } else {
                        return failure(NSError(
                            domain: "FacebookLogin",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Limited login succeeded but no AuthenticationToken"]
                        ))
                    }

                case .cancelled:
                    return cancelled()

                case .failed(let error):
                    return failure(error)
                }
            }
        }
    }

    func logout(viewController: UIViewController, call: CAPPluginCall) -> Bool {
        let loginManager = LoginManager()
        loginManager.logOut()
        return true
    }
}
