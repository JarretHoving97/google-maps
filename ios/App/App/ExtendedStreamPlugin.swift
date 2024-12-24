// swiftlint:disable all

import Capacitor
import Foundation
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public enum SuperEntitlementStatus {
    case Unavailable
    case Available
    case Active
}

@objc(ExtendedStreamPlugin)
public class ExtendedStreamPlugin: CAPPlugin, CAPBridgedPlugin {
    @Injected(\.chatClient) var chatClient

    public let identifier = "ExtendedStream"
    
    public let jsName = "ExtendedStream"
    
    public var webViewURL: URL? {
        return bridge?.config.serverURL
    }

    private(set) var chatNavigationController: UINavigationController?

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "logIn", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "logOut", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "openChannel", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "openChannels", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "setEntitlementDetails", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "setChatTrialUntil", returnType: CAPPluginReturnNone),
        CAPPluginMethod(name: "setLanguage", returnType: CAPPluginReturnNone)
    ]
    
    public static var shared = ExtendedStreamPlugin()
    
    public override func load() {
        ExtendedStreamPlugin.shared = self
        setupNavigationAppearance()
        configureChat()
    }
    
    public var superEntitlementStatus: SuperEntitlementStatus = SuperEntitlementStatus.Unavailable
    
    public var chatTrialUntil: Date?

    func initializeViewController(model: ChatPresentationModel? = nil) {
        createChat(model: model)
    }

    private func createChat(model: ChatPresentationModel? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard chatNavigationController == nil else { return }
            
            let navigation = self.composeNavigation(model: model)
            self.chatNavigationController = navigation
            self.bridge?.viewController?.present(self.chatNavigationController!, animated: true, completion: nil)
        }
    }

    @objc func logIn(_ call: CAPPluginCall) {
        guard let userId = call.getString("userId") else {
            return call.reject("Missing userId parameter.")
        }
        
        let name = call.getString("name")
        let avatarUrl = call.getString("avatarUrl")
        
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.chat.logIn(id: userId, name: name, avatarUrl: avatarUrl)
            }
        }
        
        call.resolve()
    }
    
    @objc func logOut(_ call: CAPPluginCall) {
        StreamChatWrapper.shared.logOut()
        call.resolve()
    }
    
    @objc func openChannels(_ call: CAPPluginCall) {
        initializeViewController()
        call.resolve()
    }
    
    @objc func openChannel(_ call: CAPPluginCall) {
        guard let channelId = call.getString("channelId") else { return }
        initializeViewController(
            model: ChatPresentationModel(
                channel: ChannelInfo(channelId: channelId),
                presentInStack: false
            )
        )

        call.resolve()
    }

    @objc func dismiss() {
        self.bridge?.viewController?.dismiss(animated: true)
        self.chatNavigationController = nil
    }

    @objc func notifyNavigateBackToListeners(dismiss: Bool = false) {
        notifyListeners("navigateBack", data: [:])
        
        if dismiss {
            self.dismiss()
        }
    }
    
    @objc func notifyNavigateToListeners(route: String, dismiss: Bool = false) {
        let data = JSObject(dictionaryLiteral: ("route", route), ("replace", false))
        notifyListeners("navigateTo", data: data)
        
        if dismiss {
            self.dismiss()
        }
    }
    
    @objc func setEntitlementDetails(_ call: CAPPluginCall) {
        let superStatus = call.getString("superStatus")
        
        if superStatus == "Unavailable" {
            superEntitlementStatus = SuperEntitlementStatus.Unavailable
        } else if superStatus == "Active" {
            superEntitlementStatus = SuperEntitlementStatus.Active
        } else if superStatus == "Available" {
            superEntitlementStatus = SuperEntitlementStatus.Available
        } else {
            print("[ExtendedStream] Invalid super entitlement status:", superStatus ?? [:])
        }
        
        call.resolve()
    }
    
    @objc func setChatTrialUntil(_ call: CAPPluginCall) {
        let chatTrialUntilString = call.getString("chatTrialUntil")
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        if let chatTrialUntilString, let date = formatter.date(from: chatTrialUntilString) {
            chatTrialUntil = date
        } else {
            print("[ExtendedStream] Invalid chat trial date:", chatTrialUntilString ?? [:])
        }
        
        call.resolve()
    }
    
    @objc func setLanguage(_ call: CAPPluginCall) {
        let code = call.getString("code")
        
        guard let code else {
            print("[ExtendedStream] Invalid language code:", code ?? [:])
            return call.resolve()
        }
        
        let availableLanguages = Bundle.main.localizations.filter { $0 != "Base" }
        let isAvailable = availableLanguages.contains { $0.hasPrefix(code.prefix(2)) }
        
        guard isAvailable else {
            print("[ExtendedStream] Language is not available.")
            return call.resolve()
        }
        
        LocaleSettings.shared.locale = Locale(identifier: code)
        LocaleSettings.shared.languageLocale = Locale(identifier: String(code.prefix(2)))
        
        call.resolve()
    }
    
    @objc func notifyUnreadCounts(channelUnreadCount: Int, messageUnreadCount: Int) {
        let data = JSObject(dictionaryLiteral: ("channelUnreadCount", channelUnreadCount), ("messageUnreadCount", messageUnreadCount))
        notifyListeners("unreadCounts", data: data)
    }
    
    @MainActor
    func translate(key: String, namespace: String, options: [String: JSValue] = [:]) async -> String? {
        var optionsStr = "{ "
        
        for (key, value) in options {
            optionsStr += "\"\(key)\":\"\(value)\","
        }
        
        // Remove the trailing comma and space
        if optionsStr.count > 1 {
            optionsStr.removeLast(1)
        }
        
        optionsStr += " }"
        
        do {
            let value = try await self.bridge?.webView?.evaluateJavaScript("window.translate(\"\(key)\",\"\(namespace)\",\(optionsStr))")
            
            if let value = value as? String {
                return value
            }
            
            return nil
        } catch let error {
            print(error)
            return nil
        }
    }
}

extension ExtendedStreamPlugin {
    
    private func configureChat() {
        
        guard let url = bridge?.config.serverURL else {
            
            fatalError("Implementation error: No URL found in bridge config.")
        }
        
        let config: BuildConfiguration = .create(for: url)
        
        StreamChatWrapper.shared.buildFor(environment: config)
        BuildConfiguration.safetyCheckUrl = config.AmigosApiUrl
    }
}
