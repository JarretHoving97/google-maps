//
//  Array+LocalMappable+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

extension Array where Element: LocalMappable {
    func toLocal() -> [Element.LocalType] { map { $0.toLocal() } }
}
