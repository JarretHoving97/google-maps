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

/// Contains static variables based on the scheme enviroment variable `env`.
class BuildConfiguration {

    private static var webViewURL: URL {
        if Thread.current.isMainThread {
            return getWebViewURL()
        } else {
            return DispatchQueue.main.sync(execute: getWebViewURL)
        }
    }

    static var env: Env {
        switch webViewURL.host {
        case "app.amigosapp.nl":
            return Env.production
        case "qa.app.amigosapp.nl":
            return Env.staging
        default:
            return Env.development
        }
    }

    static var StreamApiKey: String {
        switch env {
        case .development:
            return "4jwx8cxk6zhe"
        case .staging:
            return "kcmnhnu98xhw"
        default:
            return "aetbj83fpknp"
        }
    }

    static var AmigosApiUrl: String {
        switch env {
        case .development:
            return "http://\(webViewURL.host!):4000"
        case .staging:
            return "https://api.qa.app.amigosapp.nl"
        default:
            return "https://api.app.amigosapp.nl"
        }
    }
}
