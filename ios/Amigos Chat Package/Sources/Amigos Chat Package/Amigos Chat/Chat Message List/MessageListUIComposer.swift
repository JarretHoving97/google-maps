//
//  MessageListUIComposer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 09/05/2025.
//

import Foundation
import SwiftUI
import StreamChat

typealias PollControllerBuilder = (_ messageId: String, _ pollId: String) -> PollControllerProtocol?

typealias PollOptionAllVotesViewBuilder = (LocalPoll, LocalPollOption) -> LocalPollOptionAllVotesView

class MessageListUIComposer {

    static private var messageMapper = MessageMapper()

    @MainActor
    static func makeMessageListView(
        client: ChatClient,
        messages: [ChatMessageProtocol],
        messageDisplayConfig: MessageListDisplayConfiguration,
        messageGroupingInfo: [String: [String]],
        unreadMessagesCount: Int,
        scrollDirection: Binding<MessageListView.ScrollDirection>,
        isDirectMessageChat: Bool,
        firstUnreadMessageId: String?,
        isReadHandler: HasSeenHandler,
        isReadByAllHandler: @escaping IsReadByAllHandler,
        onMessageAppear: @escaping (Int, MessageListView.ScrollDirection) -> Void,
        onQuotedMessageTapHandler: @escaping QuotedMessageTapHandler,
        onMessageReplyHandler: @escaping MessageReplyHandler,
        onLongPressHandler: @escaping LongPressHandler,
        onReactionsTap: @escaping ReactionsTapHandler,
        onMessageThreadReplyTap: @escaping ThreadRepliesTapHandler,
        width: CGFloat
    ) -> some View {

        let messageList = messages.map { messageMapper.map($0) }

        let viewModel = MessageListViewModel(
            messageList: messageList,
            unreadMessagesCount: unreadMessagesCount,
            messagesGroupingInfo: messageGroupingInfo,
            isDirectMessageChat: isDirectMessageChat,
            firstUnreadMessageId: firstUnreadMessageId,
            isReadHandler: isReadHandler,
            isReadByAllHandler: isReadByAllHandler,
            config: messageDisplayConfig
        )

        viewModel.pollControllerBuilder = PollBuilderFactory.build(client: client)

        let messageGestureCallbacks = MessageGestureCallbacks(
            onQuotedMessageTap: onQuotedMessageTapHandler,
            onMessageReply: onMessageReplyHandler,
            onLongPress: onLongPressHandler,
            onReactionsTap: onReactionsTap,
            onThreadRepliesTap: onMessageThreadReplyTap
        )

        return MessageListView(
            viewModel: viewModel,
            callbacks: messageGestureCallbacks,
            width: width,
            scrollDirection: scrollDirection,
            onMessageAppear: onMessageAppear,
            pollOptionAllVotesViewBuilder: pollAllVotesViewBuilder(with: client)
        )
    }
}

extension MessageListUIComposer {

    static func pollAllVotesViewBuilder(with client: ChatClient) -> PollOptionAllVotesViewBuilder {

        return { [weak client] poll, option in

            guard let client else {
                // client is deallocated. show a view without a controller (which will not happen at all)
                // but I prever this above a crash.
                return LocalPollOptionAllVotesView(
                    viewModel: PollOptionAllVotesViewModel(
                        poll: poll,
                        option: option,
                        controller: EmptyPollVotelistController()
                    )
                )
            }

            let controller = client.pollVoteListController(
                query: PollVoteListQuery(pollId: poll.id, optionId: option.id)
            )

            let viewModel = PollOptionAllVotesViewModel(
                poll: poll,
                option: option,
                controller: StreamPollVotesAdapter(controller: controller)
            )

            let view = LocalPollOptionAllVotesView(viewModel: viewModel)

            return view
        }
    }
}

class EmptyPollVotelistController: PollVoteListControllerProtocol {

    enum Error: Swift.Error {
        case empty
    }

    var votes: [LocalPollVote] = []

    var hasLoadedAllVotes: Bool = false

    var delegate: (any LocalPollVotesProviderDelegate)?

    func synchronize(_ completion: ((Swift.Error?) -> Void)?) {
        completion?(.some(Error.empty))
    }

    func loadMoreVotes(limit: Int?, completion: ((Swift.Error?) -> Void)?) {
        completion?(.some(Error.empty))
    }
}
