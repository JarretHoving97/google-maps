import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import Capacitor
import ByteowlsCapacitorOauth2

@objc class FacebookOAuth2Handler: NSObject, OAuth2CustomHandler {

    required override init() {
    }

    func getAccessToken(viewController: UIViewController, call: CAPPluginCall, success: @escaping (String) -> Void, cancelled: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        // if let accessToken = AccessToken.current {
        //     success(accessToken.tokenString)
        // } else {
            DispatchQueue.main.async {
                let loginManager = LoginManager()
                // I only need the most basic permissions but others are available
                loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { result, error in
                    if let token = result?.token {
                        return success(token.tokenString)
                    }
                    if let error = error {
                        return failure(error)
                    }
                    if (result?.isCancelled != nil) {
                        return cancelled()
                    }
                    return cancelled()
                }
            }
        // }
    }

    func logout(viewController: UIViewController, call: CAPPluginCall) -> Bool {
        let loginManager = LoginManager()
        loginManager.logOut()
        return true
    }
}
