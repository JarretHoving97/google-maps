//
//  MessageList.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/05/2025.
//

import SwiftUI

typealias OnMessageAppearHandler = (Int, LocalScrollDirection) -> Void

struct MessageListView: View {

    typealias ScrollDirection = LocalScrollDirection

    @ObservedObject var viewModel: MessageListViewModel

    @Binding var scrollDirection: ScrollDirection

    @State private var firstUnreadMessage: Message?

    let width: CGFloat

    private let messageGestureCallBacks: MessageGestureCallbacks
    private let onMessageAppear: OnMessageAppearHandler

    init(
        viewModel: MessageListViewModel,
        callbacks: MessageGestureCallbacks = .noGestures,
        width: CGFloat = .messageWidth,
        scrollDirection: Binding<ScrollDirection>,
        onMessageAppear: @escaping OnMessageAppearHandler
    ) {
        self._scrollDirection = scrollDirection
        self.viewModel = viewModel
        self.width = width
        self.messageGestureCallBacks = callbacks
        self.onMessageAppear = onMessageAppear
    }

    var body: some View {
        ForEach(viewModel.messageList) { message in
            listItemView(message)

            if message == firstUnreadMessage {
                CustomNewMessagesIndicatorView(
                    newMessagesStartId: .constant(message.id),
                    count: viewModel.unreadMessagesCount
                )
                .flippedUpsideDown()
            }
        }
    }

    private func listItemView(_ message: Message) -> some View {

        var index: Int? = viewModel.indexForMessageDate(message: message)
        let viewData = viewModel.viewData(for: message)

        return MessageContainerView(
            viewModel: viewData,
            gestureCallbacks: messageGestureCallBacks,
            width: width
        )
        .onAppear {
            if viewModel.showUnreadMessageSeparator(for: message) {
                firstUnreadMessage = message
            }
        }
        .padding(.top, viewModel.padding(for: message))
        .flippedUpsideDown()
        .onAppear { handleOnAppear(index: &index, message: message) }
    }

    private func handleOnAppear(index: inout Int?, message: Message) {
        if index == nil {
            index = viewModel.indexForMessageDate(message: message)
        }
        if let index = index {
            onMessageAppear(index, scrollDirection)
        }
    }
}

#Preview {

    let date = Date()

    let list = [
        Message(
            isSentByCurrentUser: false,
            message: "Joo dude alles goed?"
        ),
        Message(
            isSentByCurrentUser: false,
            message: "Vroeg me af hoe het nu is"
        ),
        Message(
            isSentByCurrentUser: false,
            message: "Jaa giet weh",
            quotedMessage: {
                Message(
                    message: "Joo dude alles goed?"
                )
            }
        )
    ]

    let viewModel = MessageListViewModel(
        messageList: list,
        isDirectMessageChat: true,
        firstUnreadMessageId: nil,
        isReadHandler: DefaultsHasSeenHandler(),
        config: MessageListDisplayConfiguration()
    )

    NavigationView {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionFooters) {
                Section {
                    MessageListView(
                        viewModel: viewModel,
                        scrollDirection: .constant(.up),
                        onMessageAppear: {_, _ in }
                    )
                }
            }
            .flippedUpsideDown()
        }
    }
}
