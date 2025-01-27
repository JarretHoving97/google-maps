//
//  UserProvider.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

class UserProvider {

    static let shared = UserProvider()

    private(set) var id: String?

    private init() {}

    public func set(userId: String) {
        self.id = userId
    }

    public func delete() {
        id = nil
    }
}
