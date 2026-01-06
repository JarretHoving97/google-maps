//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

public typealias HeaderButtonActionHandler = (ChannelHeaderButtonAction) -> Void

public enum ChannelHeaderButtonAction {
    case messageHost(userId: String)
    case startCommunityActivity(communityId: String)
}

/// View for the chat channel.
public struct CustomChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.chatRouter) private var router

    @StateObject private var viewModel: ChatChannelViewModel

    private let customViewModel = CustomChatChannelViewModel()

    @State private var messageDisplayInfo: MessageDisplayInfo?

    @State private var keyboardShown = false
    @State private var tabBarAvailable: Bool = false

    private var factory: Factory

    private var scrollToMessage: ChatMessage?

    private let messageId: String?

    var onDidLoadChannel: ((ChatChannel) -> Void)?

    private let messageThreadNavigationAction: MessageThreadNavigationAction

    private let messageActionsViewBuilder: OnCreateMessageActionsFactory?

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelViewModel? = nil,
        messageId: String?,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil,
        onDidLoadChannel: ((ChatChannel) -> Void)? = nil,
        messageThreadNavigationAction: @escaping MessageThreadNavigationAction = {_ in },
        messageActionsViewBuilder: OnCreateMessageActionsFactory? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeChannelViewModel(
                with: channelController,
                messageController: messageController,
                scrollToMessage: nil
            )
        )
        factory = viewFactory
        self.onDidLoadChannel = onDidLoadChannel
        self.scrollToMessage = scrollToMessage
        self.messageId = messageId
        self.messageThreadNavigationAction = messageThreadNavigationAction
        self.messageActionsViewBuilder = messageActionsViewBuilder
    }

    public var body: some View {
        ZStack {
            if let channel = viewModel.channel {
                VStack(spacing: 0) {
                    headerActionView()

                    CustomChatChannelMessageListView(
                        viewFactory: factory,
                        channel: channel,
                        onReloadChannelHeader: onDidLoadChannel,
                        viewModel: viewModel,
                        channelController: chatClient.channelController(for: channel.cid),
                        messageThreadNavigationAction: messageThreadNavigationAction,
                        messageActionsViewBuilder: messageActionsViewBuilder
                    )
                }
                .onAppear {
                    ChatFeatureState.shared.set(screen: .channel(channelId: channel.id))
                    onDidLoadChannel?(channel)
                }

            } else {
                factory.makeChannelLoadingView()
            }
        }
        .navigationBarTitleDisplayMode(factory.navigationBarDisplayMode())
        .onReceive(keyboardWillChangePublisher, perform: { visible in
            keyboardShown = visible
        })
        .onAppear {
            viewModel.onViewAppear()
            if utils.messageListConfig.becomesFirstResponderOnOpen {
                keyboardShown = true
            }
        }
        .onDisappear {
            viewModel.onViewDissappear()
        }
        .background(
            isIphone ?
                Color.clear.background(
                    CustomTabBarAccessor { _ in
                        self.tabBarAvailable = utils.messageListConfig.handleTabBarVisibility
                    }
                )
                .allowsHitTesting(false)
                : nil
        )

        .padding(.bottom, keyboardShown || !tabBarAvailable || generatingSnapshot ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ChatChannelView")
    }

    var isIphone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private var generatingSnapshot: Bool {
        tabBarAvailable && messageDisplayInfo != nil && !viewModel.reactionsShown
    }

    /// Returns the top most view controller.
    func topVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                let children = topController.children
                if !children.isEmpty {
                    let splitVC = children[0]
                    let sideVCs = splitVC.children
                    if sideVCs.count > 1 {
                        topController = sideVCs[1]
                        return topController
                    }
                }
            }

            return topController
        }

        return nil
    }

    private var bottomPadding: CGFloat {
        let bottomPadding = topVC()?.view.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }

    @ViewBuilder
    private func headerActionView() -> some View {

        if let channel = viewModel.channel {
            switch viewModel.channel?.relatedConceptType {

            case .activity:
                if !channel.isCurrentUserOrganizer {
                    chatWithHostHeaderView
                }
            case .community:

                startCommunityActivityHeaderView

            default: EmptyView()
            }
        }
    }

    private var startCommunityActivityHeaderView: some View {

        VStack(spacing: 10) {
            Divider()
            ChannelHeaderButtonView(
                title: customViewModel.createActivityLabel,
                onButtonPress: {
                    guard let communityId = viewModel.channel?.extraData["communityId"]?.stringValue else { return }
                    router?.push(.client(.upsertCommunityActivity(id: communityId)))
                }
            )
            Divider()
        }
    }
    private var chatWithHostHeaderView: some View {
        VStack(spacing: 10) {
            Divider()
            ChannelHeaderButtonView(
                title: tr("channel.start.message.with.host"),
                onButtonPress: {
                    guard let userId = viewModel.channel?.createdBy?.id else { return }
                    Task { @MainActor in
                        guard let channel = try? await RemoteFindOrCreateChannelService().load(for: userId) else { return }
                        router?.push(.conversation(.channelInfo(.init(channelId: channel))))
                    }
                }
            )
            Divider()
        }
    }
}

/// Provides access to the the app's tab bar (if present).
struct CustomTabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomTabBarAccessor>) ->
        UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<CustomTabBarAccessor>
    ) {
        // No handling needed.
    }

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in
            // Default implementation.
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = tabBarController {
                callback(tabBar.tabBar)
            }
        }
    }
}
