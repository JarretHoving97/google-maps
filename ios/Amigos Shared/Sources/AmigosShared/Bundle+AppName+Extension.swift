//
//  Bundle+AppName+Extension.swift
//  Amigos Shared
//
//  Created by Jarret on 02/12/2025.
//

import Foundation

public extension Bundle {

    static var appBundle: Bundle {
        var bundle = Bundle.main
        // If we're in .appex: Two levels up -> App.app
        if bundle.bundleURL.pathExtension == "appex" {
            let url = bundle.bundleURL
                .deletingLastPathComponent()   // .../PlugIns
                .deletingLastPathComponent()   // .../MyApp.app

            if let appBundle = Bundle(url: url) {
                bundle = appBundle
            }
        }

        return bundle
    }

    /// Display name host-app (of fallback).
    static var appDisplayName: String {
        let bundle = Bundle.appBundle

        return bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Amigos" // fallback
    }
}
