import Foundation
import FacebookCore
import FacebookLogin
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
                loginManager.logIn(permissions: [ .publicProfile, .email ], viewController: viewController) { result in
                    switch result {
                    case .success(_, _, let accessToken):
                        success(accessToken.tokenString)
                    case .failed(let error):
                        failure(error)
                    case .cancelled:
                        cancelled()
                    }
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
