//
//  BuildConfiguration.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import Foundation

enum Env: String {
    case development
    case staging
    case production
}

public enum BuildConfiguration {

    case production
    case staging
    case development(host: String)

    public var amigosApiUrl: String {
        switch self {

        case .production:
            return "https://api.app.amigosapp.nl"

        case .staging:
            return "https://api.qa.app.amigosapp.nl"

        case let .development(host):
            return "http://\(host):4000"
        }
    }

    public var env: String {
        switch self {

        case .production:
            return "https://app.amigosapp.nl"

        case .staging:
            return "https://qa.app.amigosapp.nl"

        case .development(let host):
            return "http://\(host):5173"
        }
    }

    public var streamApiKey: String {
        switch self {

        case .development:
            return "4jwx8cxk6zhe"

        case .staging:
            return "6ur6es9uw86j"

        default:
            return "aetbj83fpknp"
        }
    }
}

public extension BuildConfiguration {

    // Compares url to environment and retrieves the configuration.
    static func create(for url: URL) -> BuildConfiguration {

        let urlString = url.absoluteString

        if urlString == BuildConfiguration.staging.env {
            return .staging
        }

        if urlString == BuildConfiguration.production.env {
            return .production
        }

        guard let host = url.host else {
            fatalError("Invalid host from development url.")
        }

        return .development(host: host)
    }
}
