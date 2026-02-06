//
//  ChatNavigationView..swift
//  Amigos Chat Package
//
//  Created by Jarret on 08/12/2025.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

public struct ChatNavigationView: View {

    public enum Root {
        case channels
        case conversation(ChatRoute.Conversation)
    }

    @ObservedObject private var viewModel: ChatNavigationViewModel
    private let destinationResolver: ChatDestinationResolver
    private let uiFactory: CustomUIFactory
    private let channelListController = ChatControllers.channelListController!
    private let root: Root

    public init(
        viewModel: ChatNavigationViewModel,
        uiFactory: CustomUIFactory,
        appInfo: AppInfo?,
        root: Root,
        destinationResolver: ChatDestinationResolver
    ) {
        self.viewModel = viewModel
        self.uiFactory = uiFactory
        self.destinationResolver = destinationResolver
        self.root = root
        InjectedValues[\.chatRouter] = AnyRouter(viewModel)
        InjectedValues[\.appInfo] = appInfo
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            rootView()
                .navigationDestination(
                    for: ChatRoute.self,
                    destination: destinationResolver.view
                )
        }
        .onChange(of: viewModel.path) { oldValue, newValue in
            viewModel.handlePathChange(from: oldValue, to: newValue)
        }
        .modifier(ConditionalTint())
    }

    @ViewBuilder
    private func rootView() -> some View {
        switch root {
        case .channels:
            ChatScreen(
                with: uiFactory,
                channelListController: channelListController,
                chatViewModel: ChatViewModel(),
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
        case let .conversation(conversation):
            destinationResolver.view(for: .conversation(conversation))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        closeButton
                    }
                }
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button {
            viewModel.close()
        } label: {
            Image(.xMark)
                .foregroundStyle(Color(.greyDark))
        }
    }
}

// only add tint for the toolbar in <iOS26
struct ConditionalTint: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content.tint(Color(.purple))
        }
    }
}
