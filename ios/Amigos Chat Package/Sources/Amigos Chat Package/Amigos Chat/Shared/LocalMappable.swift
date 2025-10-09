//
//  LocalMappable.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

public protocol LocalMappable {
    associatedtype LocalType
    func toLocal() -> LocalType
}
