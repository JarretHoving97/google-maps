import Foundation
import SwiftKeychainWrapper

private let keychain = KeychainWrapper.init(serviceName: "cap_sec")

/// Gets the `jwt` amigos auth token which should have been set by the Capacitor client.
func getValueFromKeychain(key: String) -> String? {
    let hasValueDedicated = keychain.hasValue(forKey: key)
    let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)

    if hasValueStandard && !hasValueDedicated {
        keychain.set(
            KeychainWrapper.standard.string(forKey: key) ?? "",
            forKey: key,
            withAccessibility: .afterFirstUnlock
        )

        KeychainWrapper.standard.removeObject(forKey: key)
    }

    return keychain.string(forKey: key)
}
