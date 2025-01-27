//
//  KeychainLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

class KeychainController {

    static private(set) var jwtLoader: KeychainLoader?

    private init() {}

    public static func setJwtLoader(_ loader: KeychainLoader) {
        self.jwtLoader = loader
    }
}
