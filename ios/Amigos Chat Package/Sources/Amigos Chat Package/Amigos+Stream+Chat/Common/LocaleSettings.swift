//
//  LocaleSettings.swift
//  Amigos Chat Package
//
//  Created by Jarret on 09/01/2025.
//

import SwiftUI

public class LocaleSettings {

    public var locale = Locale.current

    public var languageLocale = Locale(identifier: String(Locale.current.identifier.prefix(2)))

    public static var shared = LocaleSettings()

    public var bundle: Bundle? {
        guard let path = Bundle.module.path(forResource: languageLocale.identifier, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return nil
        }

        return bundle
    }
}
