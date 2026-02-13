//
//  Localize.swift
//  Amigos Chat Package
//
//  Created by Jarret on 17/02/2025.
//

import Foundation

final class Localized {

    static var bundle: Bundle {
        LocaleSettings.shared.bundle ?? Bundle(for: Localized.self)
    }

    static func localized(_ key: String, table: String) -> String {
        NSLocalizedString(key, tableName: table, bundle: bundle, value: key, comment: "")
    }
}
