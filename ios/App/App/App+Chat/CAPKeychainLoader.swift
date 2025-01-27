import Foundation
import SwiftKeychainWrapper
import Amigos_Chat_Package

class CAPKeyChainLoader: KeychainLoader {

    private let keychain = KeychainWrapper.init(serviceName: "cap_sec")

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
}
