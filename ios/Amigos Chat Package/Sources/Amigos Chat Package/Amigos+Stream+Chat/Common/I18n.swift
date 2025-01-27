import StreamChatSwiftUI
import Foundation

func tr(_ key: String, _ args: CVarArg...) -> String {
    guard let bundle = LocaleSettings.shared.bundle else {
        return key
    }

    let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

    return String(format: localizedString, arguments: args)
}
