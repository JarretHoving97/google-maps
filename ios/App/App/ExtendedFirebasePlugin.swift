//
//  FirebaseAppCheckPlugin.swift
//  App
//
//  Created by Jarret on 20/03/2026.
//

import Foundation
import Capacitor
import FirebaseAppCheck

@objc(ExtendedFirebasePlugin)
public class ExtendedFirebasePlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "ExtendedFirebase"
    public let jsName = "ExtendedFirebase"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getAppCheckToken", returnType: CAPPluginReturnPromise),
    ]

    @objc func getAppCheckToken(_ call: CAPPluginCall) {
        let forceRefresh = call.getBool("forceRefresh") ?? false

        FirebaseAppCheck.shared.getToken(forceRefresh: forceRefresh) { result in
            switch result {
            case let .success(token):
                var result = JSObject()
                result["token"] = token
                call.resolve(result)

            case let .failure(error):
                call.resolve()
            }
        }
    }
}
