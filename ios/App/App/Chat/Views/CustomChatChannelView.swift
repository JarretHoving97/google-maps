//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View for the chat channel.
public struct CustomChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @StateObject private var viewModel: ChatChannelViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var messageDisplayInfo: MessageDisplayInfo?
    @State private var keyboardShown = false
    @State private var tabBarAvailable: Bool = false

    private var factory: Factory

    private var scrollToMessage: ChatMessage?

    private let messageId: String?
    var onChatWithHostTapped: ((String?) -> Void)?

    var onDidLoadChannel: ((ChatChannel) -> Void)?

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelViewModel? = nil,
        messageId: String?,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil,
        onDidLoadChannel: ((ChatChannel) -> Void)? = nil,
        onChatWithHostTapped: ((String?) -> Void)? = nil

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
        self.onChatWithHostTapped = onChatWithHostTapped
        self.scrollToMessage = scrollToMessage
        self.messageId = messageId
    }

    public var body: some View {
        ZStack {
            if let channel = viewModel.channel {
                VStack(spacing: 0) {
                    if !channel.isDirectMessageChannel && !channel.isCurrentUserOrganizer {
                        chatWithHostView
                    }
                    CustomChatChannelMessageListView(
                        viewFactory: factory,
                        channel: channel,
                        viewModel: viewModel,
                        channelController: chatClient.channelController(for: channel.cid)
                    )
                }
                .onAppear {
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
        .onChange(of: presentationMode.wrappedValue, perform: { newValue in
            if newValue.isPresented == false {
                viewModel.onViewDissappear()
            } else {
                viewModel.setActive()
            }
        })
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

    private var chatWithHostView: some View {
        VStack {
            Divider()
            ChatWithHostView(onChatWithHostTapped: { onChatWithHostTapped?(viewModel.channel?.createdBy?.id) })
                .frame(height: 32)
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
