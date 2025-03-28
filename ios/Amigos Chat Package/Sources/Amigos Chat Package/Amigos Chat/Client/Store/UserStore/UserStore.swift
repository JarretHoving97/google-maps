//
//  UserJWTInformationStore.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/03/2025.
//

import Foundation

fileprivate extension String {
    static let idStoreKey = "amigos.chat.client.user.id"
    static let imageUrlStoreKey = "amigos.chat.client.user.imageurl"
    static let nameStoreKey = "amigos.chat.client.user.name"
}

public class UserStore {

    private let userDefaults: UserDefaults

    public init(suiteName: String) {
        self.userDefaults = UserDefaults(suiteName: suiteName)!
    }

    public func store(info: UserData) {
        userDefaults.set(info.id, forKey: .idStoreKey)
        userDefaults.set(info.imageUrl, forKey: .imageUrlStoreKey)
        userDefaults.set(info.name, forKey: .nameStoreKey)
    }

    public func retrieve() -> UserData? {
        guard
            let id = userDefaults.string(forKey: .idStoreKey),
            let imageUrl = userDefaults.string(forKey: .imageUrlStoreKey),
            let name = userDefaults.string(forKey: .nameStoreKey)
        else {
            return nil
        }

        return UserData(id: id, imageUrl: imageUrl, name: name)
    }

    public func clear() {
        userDefaults.removeObject(forKey: .idStoreKey)
        userDefaults.removeObject(forKey: .imageUrlStoreKey)
        userDefaults.removeObject(forKey: .nameStoreKey)
    }
}
