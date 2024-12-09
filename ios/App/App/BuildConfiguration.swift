// swiftlint:disable all
import Foundation

// The best way to do environment variables seems to be using `xcconfig` files.
// Not entirely sure how though so we will just use this class for the time being.

enum Env: String {
    case development
    case staging
    case production
}

func getWebViewURL() -> URL {
    if let webViewUrl = ExtendedStreamPlugin.shared.bridge?.config.serverURL {
        return webViewUrl
    }

    fatalError("[BuildConfiguration] Invalid WebView host.")
}

public enum BuildConfiguration {

    // TODO: Make use of composition.
    static var safetyCheckUrl: String = ""

    case production
    case staging
    case development(hostURL: String)

    var AmigosApiUrl: String {
        switch self {

        case .production:
            return "https://api.app.amigosapp.nl"

        case .staging:
            return "https://api.qa.app.amigosapp.nl"

        case let .development(hostURL):
            return "http://\(hostURL):4000"
        }
    }

    var env: String {
        switch self {

        case .production:
            return "https://app.amigosapp.nl"

        case .staging:
            return "https://qa.app.amigosapp.nl"

        case .development(let hostURL):
            return hostURL
        }
    }

    var StreamApiKey: String {
        switch self {

        case .development:
            return "4jwx8cxk6zhe"

        case .staging:
            return "kcmnhnu98xhw"

        default:
            return "aetbj83fpknp"
        }
    }
}

extension BuildConfiguration {

    // Compares url to environment and retrieves the configuration.
    static func create(for url: URL) -> BuildConfiguration {

        let urlString = url.string

        if urlString == BuildConfiguration.staging.env {
            return .staging
        }

        if urlString == BuildConfiguration.production.env {
            return .production
        }

        return .development(hostURL: urlString)
    }
}
