//
//  KeychainLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

public protocol KeychainLoader {
    func getValueFromKeychain(key: String) -> String?
}

