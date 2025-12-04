//
//  MessageContainerView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/02/2025.
//

import SwiftUI

struct MessageContainerView: View {

    @ObservedObject var viewModel: MessageContainerViewModel
    @State private var frame: CGRect = .zero
    @State private var computeFrame: Bool = false

    private let width: CGFloat
    private let gestureCallbacks: MessageGestureCallbacks
    private let avatarSize: CGFloat = 32
    private let pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?

    init(
        viewModel: MessageContainerViewModel,
        gestureCallbacks: MessageGestureCallbacks = .noGestures,
        width: CGFloat = .messageWidth,
        pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?
    ) {
        self.viewModel = viewModel
        self.gestureCallbacks = gestureCallbacks
        self.width = width
        self.pollOptionAllVotesViewBuilder = pollOptionAllVotesViewBuilder
    }

    var body: some View {

        let alignment: HorizontalAlignment = viewModel.isRightAligned ? .trailing : .leading

        HStack(alignment: .bottom, spacing: 6) {

            if viewModel.showLeftPadding {
                avatarView
            }

            if viewModel.isRightAligned {
                MessageSpacer(spacerWidth: defaultSpacerWidth(width))
            }

            VStack(
                alignment: alignment,
                spacing: 0
            ) {

                nameLabel

                VStack(
                    alignment: alignment,
                    spacing: 2
                ) {
                    content
                    threadRepliesView
                    footerView
                }
            }

            if !viewModel.isRightAligned {
                MessageSpacer(spacerWidth: defaultSpacerWidth(width))
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, viewModel.showFooterView ? 20 : 2)
    }

    public var defaultSpacerWidth: (CGFloat) -> (CGFloat) {
        { availableWidth in
            return availableWidth / 4
        }
    }

    private var contentWidth: CGFloat {
        let padding: CGFloat = 8
        let minimumWidth: CGFloat = 240
        let avatarSize: CGFloat = avatarSize + padding
        let availableWidth = max(minimumWidth, width - spacerWidth) - 2 * padding
        return availableWidth - avatarSize
    }

    private var spacerWidth: CGFloat {
        defaultSpacerWidth(width)
    }

    private func longTapGesture() {
        computeFrame = true
        triggerHapticFeedback(style: .medium)
    }

    func navigateToOnboardingWebView() {
        if viewModel.layoutKey == "onboarding" {
            RouteController.routeAction?(RouteInfo(route: .superAmigoRoute, dismiss: true) )

        } else if viewModel.layoutKey == "how_to_host" {
            RouteController.routeAction?(RouteInfo(route: .howToHost, dismiss: true))

        } else if viewModel.layoutKey == "how_to_join" {
            RouteController.routeAction?(RouteInfo(route: .howToJoin, dismiss: true))
        }
    }

    private func navigateToProfileWebView() {
        let userId = viewModel.message.user.id
        RouteController.routeAction?(RouteInfo(route: .profileRoute(id: userId), dismiss: true))
    }

    private func showReactions() {
        viewModel.showReactionsOverlay.toggle()
    }
}

struct MessageSpacer: View {
    var spacerWidth: CGFloat?

    var body: some View {
        Spacer()
            .frame(minWidth: spacerWidth)
            .layoutPriority(-1)
    }
}
// MARK: Subviews
extension MessageContainerView {

    @ViewBuilder private var content: some View {
        ZStack(alignment: viewModel.isRightAligned ? .bottomTrailing : .bottomLeading) {

            VStack(alignment: viewModel.isRightAligned ? .trailing : .leading, spacing: 0) {
                MessageView(
                    viewModel: MessageViewModel(
                        message: viewModel.message,
                        imageLoader: viewModel.imageLoader,
                        imageCDN: viewModel.imageCDN,
                        videoPreviewLoader: viewModel.videoPreviewLoader,
                        pollAttachment: viewModel.messagePollViewData,
                        messagePosition: viewModel.position
                        ),
                        maxWidth: contentWidth,
                        onQuotedMessageTap: gestureCallbacks.onQuotedMessageTap,
                        pollOptionViewBuilder: pollOptionAllVotesViewBuilder
                )
                .messageGestures(
                    disabled: viewModel.isDisabled,
                    onSwipe: { gestureCallbacks.onMessageReply(viewModel.message.id) },
                    onLongPress: { longTapGesture() }
                )
                .background(
                    GeometryReader { proxy in
                        Rectangle().fill(Color.clear)
                            .onChange(of: computeFrame, perform: { _ in
                                DispatchQueue.main.async {
                                    gestureCallbacks.onLongPress(
                                        LocalMessageInfo(
                                            id: viewModel.message.id,
                                            frame: (proxy.frame(in: .global)),
                                            pollViewData: viewModel.messagePollViewData
                                        )
                                    )
                                    computeFrame = false
                                }
                            })
                    }
                )
                .onTapGesture {
                    navigateToOnboardingWebView()
                }
                .padding(
                    .top,
                    viewModel.showReactionsOverlay ? 24 : 0)

                if !viewModel.reactions.isEmpty {
                    MessageBottomReactionsView(
                        viewModel: MessageBottomReactionsViewModel(reactions: viewModel.reactions)
                    )
                    .padding(.top, -6)
                    .padding(.horizontal, 8)

                    .onTapGesture {
                        gestureCallbacks.onReactionsTap(MessageReactionsInfo(id: viewModel.message.id))
                    }
                }
            }
        }
    }

    private var footerView: some View {
        Group {
            if viewModel.showFooterView {
                if viewModel.isDirectMessageChat {
                    directMessageChatFooter(isCurrentUser: viewModel.isRightAligned)
                } else {
                    groupChatFooter(isCurrentUser: viewModel.isRightAligned)
                }
            }
        }
    }

    @ViewBuilder private func groupChatFooter(isCurrentUser: Bool) -> some View {

        if isCurrentUser {
            HStack(spacing: 6) {

                Spacer()

                ReadIndicatorView(
                    viewModel: ReadIndicatorViewModel(
                        isRead: viewModel.isRead,
                        isReadByAll: viewModel.isReadByAll,
                        localState: viewModel.sendingState
                    )
                )
                timeView
                    .padding(.trailing, 8)
            }
        } else {

            HStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 4) {
                    timeView
                        .padding(.leading, 8)
                }
                .accessibilityIdentifier("MessageDateView")
            }
        }
    }

    @ViewBuilder private func directMessageChatFooter(isCurrentUser: Bool) -> some View {
        HStack(spacing: 4) {
            if isCurrentUser {
                ReadIndicatorView(
                    viewModel: ReadIndicatorViewModel(
                        isRead: viewModel.isRead,
                        isReadByAll: viewModel.isReadByAll,
                        localState: viewModel.sendingState
                    )
                )
            }
            timeView
        }
    }

    private var timeView: some View {
        Text(viewModel.timeLabel)
            .font(.footnote1)
            .foregroundColor(Color(.black).opacity(0.6))
    }

    private var avatarView: some View {
        VStack {
            Spacer()
            if viewModel.showAvatar {
                AvatarView(
                    imageUrl: viewModel.author.imageUrl,
                    size: avatarSize
                )
                .onTapGesture { navigateToProfileWebView() }
            } else {
                ZStack {
                    Color.clear
                        .frame(width: avatarSize)
                }
            }
        }
    }

    @ViewBuilder
    private var nameLabel: some View {
        if viewModel.showNameForMessageGroup {
            Text(viewModel.author.name)
                .font(Font.custom(size: 12, weight: .bold))
                .lineLimit(1)
                .foregroundColor(colorByString(viewModel.author.name))
                .padding(.horizontal, 8)
        }
    }

    @ViewBuilder private var threadRepliesView: some View {
        if viewModel.showMessageThreadReplies {
            MessageThreadParticipantView(
                viewData: viewModel.activeThreadViewData,
                isRightAligned: viewModel.isRightAligned
            )
            .padding(.horizontal, 8)
            .padding(.bottom, !viewModel.showFooterView ? 8 : 0)
            .onTapGesture(perform: { gestureCallbacks.onThreadRepliesTap(viewModel.message.id)})
            .frame(maxWidth: .infinity)
        }
    }
}

struct MessageThreadParticipantView: View {

    private let viewModel: ActiveThreadIndicatorViewData

    private let isRightAligned: Bool

    init(viewData: ActiveThreadIndicatorViewData, isRightAligned: Bool) {
        self.viewModel = viewData
        self.isRightAligned = isRightAligned
    }

    var body: some View {

        if !viewModel.isEmpty {
            HStack(spacing: 6) {

                if isRightAligned {
                    Spacer()
                }
                // MARK: Disabled to match with android
                /*  HStack(spacing: -8) {
                 ForEach(viewModel.participants.prefix(3)) { user in
                 AvatarView(imageUrl: user.imageUrl, size: 20)
                 }
                 }
                 .frame(height: 24)

                 */

                Text(viewModel.replyLabel)
                    .font(.caption2)
                    .foregroundStyle(Color(.purple))

                if !isRightAligned {
                    Spacer()
                }
            }
        }
    }
}

#Preview {

    MessageContainerView(
        viewModel: MessageContainerViewModel(
            message: Message(
                user: LocalUser(
                    id: .uniqueID,
                    name: "Ilon",
                    imageUrl: ImageURLExamples.portraitImageUrl
                ),
                message: "Hallo there!"
            ),
            showsAllInfo: true, messagePosition: {_ in .top},
            isDirectMessageChat: false,
            isRead: false,
            pollController: MockPollController(localOwnVotes: [])
        ), pollOptionAllVotesViewBuilder: nil
    )
}

#Preview {
    MessageContainerView(
        viewModel: MessageContainerViewModel(
            message: Message(
                user: LocalUser(
                    id: .uniqueID,
                    name: "Ilon",
                    imageUrl: ImageURLExamples.portraitImageUrl
                ),
                isSentByCurrentUser: false,
                message: "",
                isDeleted: false,
                attachments: [.image(
                    ImageAttachment(
                        imageUrl: ImageURLExamples.landscapeImageUrl,
                        uploadingState: .none
                    )
                )],
            ),
            showsAllInfo: true,
            isDirectMessageChat: false
        ),
        width: UIScreen.main.bounds.width,
        pollOptionAllVotesViewBuilder: nil
    )
}

#Preview {
    MessageContainerView(
        viewModel: MessageContainerViewModel(
            message: Message(
                user: LocalUser(
                    id: .uniqueID,
                    name: "Ilon",
                    imageUrl: ImageURLExamples.portraitImageUrl
                ),
                isSentByCurrentUser: false,
                message: "a",
                isDeleted: false,
                layoutKey: "system",
                replyCount: 4,
                threadParticipants: [
                    LocalChatUser(
                        id: UUID().uuidString,
                        name: "",
                        imageUrl: ImageURLExamples.landscapeImageUrl
                    ),           LocalChatUser(
                        id: UUID().uuidString,
                        name: "",
                        imageUrl: ImageURLExamples.landscapeImageUrl
                    ),
                    LocalChatUser(
                        id: UUID().uuidString,
                        name: "",
                        imageUrl: ImageURLExamples.landscapeImageUrl
                    )
                ]
            ),
            showsAllInfo: true,
            isDirectMessageChat: false
        ),
        width: UIScreen.main.bounds.width,
        pollOptionAllVotesViewBuilder: nil
    )
}
