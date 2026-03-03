// swiftlint:disable all

import Capacitor
import Foundation
import SwiftUI
import StreamChatSwiftUI
import StreamChat
import Amigos_Chat_Package

@objc(ExtendedStreamPlugin)
public class ExtendedStreamPlugin: CAPPlugin, CAPBridgedPlugin, ClientNavigationNotifier {

    var chatRouter: ChatNavigationViewModel?

    static private(set) var chatClient: AmigosChatClient!

    private var client: ChatClient {
        return Self.chatClient.chatClient
    }

    public let identifier = "ExtendedStream"

    public let jsName = "ExtendedStream"

    public var webViewURL: URL? {
        return bridge?.config.serverURL
    }

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
        configureChat()
    }

    public var chatTrialUntil: Date?

    func initializeViewController(model: ChatPresentationModel? = nil) {
        guard chatRouter == nil else {
            debugPrint("Initialize called while already initialized")
            return
        }
        createChat(model: model)
    }

    private func createChat(model: ChatPresentationModel? = nil) {

        guard ExtendedStreamPlugin.chatClient.isConfigured else { return }

        DispatchQueue.main.async { [weak self] in

            guard let self else { return }

            let client = ExtendedStreamPlugin.chatClient.chatClient

            let viewModel = ChatNavigationViewModel(
                client: client,
                clientNavigationReceiver: self
            )

            self.chatRouter = viewModel

            let root: ChatNavigationView.Root = {
                guard let model else { return .channels }

                if model.showChatOnly {
                    return .conversation(.channelInfo(model.channel))
                } else {
                    viewModel.setStack([.conversation(.channelInfo(model.channel))])
                    return .channels
                }
            }()

            let view = ChatNavigationView(
                viewModel: viewModel,
                uiFactory: CustomUIFactory(),
                appInfo: getAppInfo(),
                root: root,
                destinationResolver: ChatDestinationResolver(
                    client: client,
                    chatRouteInfoBuilder: ChatRouteInfoBuilder(client: client),
                    router: AnyRouter(viewModel)
                )
            )

            let hosting = UIHostingController(rootView: view)
            hosting.modalPresentationStyle = .fullScreen

            self.bridge?.viewController?.present(hosting, animated: true, completion: nil)
        }
    }

    @objc func logIn(_ call: CAPPluginCall) {
        guard let userId = call.getString("userId") else {
            return call.reject("Missing userId parameter.")
        }

        let name = call.getString("name")
        let avatarUrl = call.getString("avatarUrl") ?? ""

        Task {
            do {
                try await ExtendedStreamPlugin.chatClient?.login(
                    with: AmigosChatClient.LoginInfo(
                        id: userId,
                        name: name ?? "",
                        imageUrl: URL(string: avatarUrl)
                    )
                )
            } catch {
                print(error.localizedDescription)
            }
        }
        call.resolve()
    }

    @objc func logOut(_ call: CAPPluginCall) {

        Task {
            await ExtendedStreamPlugin.chatClient?.logout()
        }

        call.resolve()
    }

    @objc func openChannels(_ call: CAPPluginCall) {
        Task {
            do {
                try await ensureAuthentication()

                if let channel = call.getString("channelId"), !channel.isEmpty {
                    let channelInfo = ChatPresentationModel(
                        channel: ChannelInfo(channelId: channel)
                    )

                    initializeViewController(model: channelInfo)
                } else {
                    initializeViewController()
                }

                call.resolve()

            } catch {
                print("❌ error opening channel: \(error.localizedDescription)")
            }
        }
    }

    @objc func openChannel(_ call: CAPPluginCall) {

        Task {
            do {
                guard let channelId = call.getString("channelId") else { return }

                try await ensureAuthentication()

                initializeViewController(
                    model: ChatPresentationModel(
                        channel: ChannelInfo(channelId: channelId),
                        showChatOnly: true
                    )
                )

                call.resolve()
            } catch {
                print("❌ error opening channels: \(error.localizedDescription)")
            }
        }

    }

    @objc func dismiss() {
        self.bridge?.viewController?.dismiss(animated: true)
        self.chatRouter = nil
        // TODO: Can be replaced by checking the ChatNavigationViewModel
        ChatFeatureState.shared.set(screen: .none)
    }

    @objc public func notifyNavigateBackToListeners(dismiss: Bool = false) {
        notifyListeners("navigateBack", data: [:])

        if dismiss {
            self.dismiss()
        }
    }

    @objc public func notifyNavigateToListeners(route: String?, dismiss: Bool = false) {
        if let route {
            let data = JSObject(dictionaryLiteral: ("route", route), ("replace", false))
            notifyListeners("navigateTo", data: data)
        }
        if dismiss {
            self.dismiss()
        }
    }

    @objc func setEntitlementDetails(_ call: CAPPluginCall) {

        if let superStatusValue = call.getString("superStatus") {

            if let status = SuperEntitlementStatus(rawValue: superStatusValue) {
                InjectedValues[\.superStatus].superEntitlementStatus = status
            } else {
                print("[ExtendedStream] Invalid super entitlement status:", superStatusValue)
            }
        } else {
            print("[ExtendedStream] did not receive any superStatus value")
        }

        call.resolve()
    }

    @objc func setChatTrialUntil(_ call: CAPPluginCall) {
        let chatTrialUntilString = call.getString("chatTrialUntil")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if let chatTrialUntilString, let date = formatter.date(from: chatTrialUntilString) {
            InjectedValues[\.superStatus].chatTrialUntil = date
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

    func ensureAuthentication() async throws {
        try await Self.chatClient.ensureAuthentication()
    }
}

extension ExtendedStreamPlugin {

    private func configureChat() {

        guard let url = bridge?.config.serverURL else {
            fatalError("Implementation error: No URL found in bridge config.")
        }

        setupNavigationAppearance()

        setupPageControlAppearance()

        /// Setup Share location
        CustomUIFactory.shareCurrentLocationView = ShareLocationMapView(
            locationService: CoreLocationManager()
        )

        /// setup keychain loader
        let keychainLoader = CAPKeychainLoader()
        let config: BuildConfiguration = .create(for: url)

        /// set translation handler
        TranslationController.set {
            await ExtendedStreamPlugin.shared.translate(
                key: $0.key,
                namespace: $0.namespace,
                options: $0.options as? [String: JSValue] ?? [:]
            )
        }


        let client = AmigosChatClient(
            config: .init(
                environment: config,
                isLocalStorageEnabled: true,
                applicationGroupIdentifier: "group.com.whoisup.app.stream",
                maxAttachmentCountPerMessage: 10,
                apiKey: config.streamApiKey
            ),
            tokenProvider: CapacitorTokenLoader(
                url: config.amigosApiUrl,
                keychainLoader: keychainLoader
            ),
            pushConfig: StreamPushConfig(),
            userDelegate: CurrentUserModel(
                onDidChangeUnreadCount: { unreadCount in
                    ExtendedStreamPlugin.shared.notifyUnreadCounts(
                        channelUnreadCount: unreadCount.channels,
                        messageUnreadCount: unreadCount.messages
                    )
                }
            ),
            keychainLoader: keychainLoader,
            jwtTokenStore: LocalChatJWTtokenStore(),
            apiKeyStore: LocalChatApiKeyStore()
        )

        /// create client
        ExtendedStreamPlugin.chatClient = client

    }

    func setupNavigationAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backgroundEffect = .none

        let standardAppearance = UINavigationBarAppearance()

        if #available(iOS 26.0, *) {
            // On iOS 26 and later, keep default background (no explicit white)
        } else {
            standardAppearance.backgroundColor = .white
        }

        let foregroundColor = UIColor(named: "Grey Dark")!

        let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: foregroundColor,
            .font: UIFont(name: "Poppins-Bold", size: 30)!,
            .baselineOffset: 12
        ]

        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: foregroundColor,
            .font: UIFont(name: "Poppins-Bold", size: 15)!
        ]

        standardAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        standardAppearance.titleTextAttributes = titleTextAttributes

        navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        navigationBarAppearance.titleTextAttributes = titleTextAttributes

        let navBar = UINavigationBar.appearance()

        // Remove back button text
        let normalTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        let normalTitlePositionAdjustment = UIOffset(horizontal: -50, vertical: 0)

        navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes = normalTitleTextAttributes
        navigationBarAppearance.backButtonAppearance.normal.titlePositionAdjustment = normalTitlePositionAdjustment

        standardAppearance.backButtonAppearance.normal.titleTextAttributes = normalTitleTextAttributes
        standardAppearance.backButtonAppearance.normal.titlePositionAdjustment = normalTitlePositionAdjustment

        navBar.standardAppearance = standardAppearance
        navBar.scrollEdgeAppearance = navigationBarAppearance
        navBar.compactAppearance = navigationBarAppearance
    }

    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(.purple))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(Color(.purple)).opacity(0.3))
    }
}

