//
//  CurrentEnvironment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

class CurrentEnvironment {

    static private(set) var apiUrl: URL?
    static private(set) var url: URL?
    
    private init() {}

    public static func set(apiUrl: URL, url: URL) {
        self.apiUrl = apiUrl
        self.url = url
    }
}
