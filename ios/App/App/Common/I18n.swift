import Capacitor
import StreamChatSwiftUI

func webViewTranslate(_ key: String, namespace: String, options: [String: JSValue] = [:]) async -> String? {
    return await ExtendedStreamPlugin.shared.translate(key: key, namespace: namespace, options: options)
}

func tr(_ key: String, _ args: CVarArg...) -> String {
    guard let bundle = LocaleSettings.shared.bundle else {
        return key
    }

    let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

    return String(format: localizedString, arguments: args)
}
