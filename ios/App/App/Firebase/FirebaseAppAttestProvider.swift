//
//  FirebaseAppAttestProvider.swift
//  App
//
//  Created by Jarret on 26/03/2026.
//

import FirebaseCore
import FirebaseAppCheck

class FirebaseAppAttestProvider: NSObject, AppCheckProviderFactory {

  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    #if DEBUG
      let provider = AppCheckDebugProvider(app: app)
      print("[AppCheck] Debug token:", provider?.localDebugToken() ?? "unavailable")
      return provider
    #else
      return AppAttestProvider(app: app)
    #endif
  }
}
