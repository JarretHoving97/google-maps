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

    init(
        viewModel: MessageContainerViewModel,
        gestureCallbacks: MessageGestureCallbacks = .noGestures,
        width: CGFloat = .messageWidth
    ) {
        self.viewModel = viewModel
        self.gestureCallbacks = gestureCallbacks
        self.width = width
    }

    var body: some View {

        HStack(alignment: .bottom) {

            avatarView

            if viewModel.isRightAligned {
                MessageSpacer(spacerWidth: defaultSpacerWidth(width))
            }
             VStack(
                alignment: viewModel.isRightAligned ? .trailing : .leading,
                spacing: viewModel.message.reactions.isEmpty ? 10 : 18
            ) {
                messageView
                footerView
            }

            if !viewModel.isRightAligned {
                MessageSpacer(spacerWidth: defaultSpacerWidth(width))
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, viewModel.showsAllInfo ? 20 : 2)
        .padding(.top, viewModel.isLast ? 20 : 0)
        .padding(.bottom, !viewModel.message.reactions.isEmpty ? 16 : 0)
    }

    public var defaultSpacerWidth: (CGFloat) -> (CGFloat) {
        { availableWidth in
            if isIPad && availableWidth > 500 {
                return 2 * availableWidth / 3
            } else {
                return availableWidth / 4
            }
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

    @ViewBuilder private var messageView: some View {

        ZStack(alignment: viewModel.isRightAligned ? .bottomTrailing : .bottomLeading) {
            MessageView(
                viewModel: MessageViewModel(
                    message: viewModel.message,
                    imageLoader: viewModel.imageLoader,
                    imageCDN: viewModel.imageCDN,
                    videoPreviewLoader: viewModel.videoPreviewLoader,
                    isFirst: viewModel.showsAllInfo
                ),
                maxWidth: contentWidth,
                onQuotedMessageTap: gestureCallbacks.onQuotedMessageTap
            )
            .messageGestures(
                onSwipe: { gestureCallbacks.onMessageReply(viewModel.message.id) },
                onLongPress: { longTapGesture() }
            )
            .background(
                GeometryReader { proxy in
                    Rectangle().fill(Color.clear)
                        .onChange(of: computeFrame, perform: { _ in
                            DispatchQueue.main.async {
                                gestureCallbacks.onLongPress(LocalMessageInfo(id: viewModel.message.id, frame: (proxy.frame(in: .global))))
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
                viewModel.showReactionsOverlay ? 24 : 0
            )

            if !viewModel.reactions.isEmpty {
                MessageBottomReactionsView(
                    viewModel: MessageBottomReactionsViewModel(reactions: viewModel.reactions)
                )
                .padding(
                    EdgeInsets(
                        top: 10,
                        leading: 10,
                        bottom: -14,
                        trailing: 10
                    )
                )
                .onTapGesture {
                    gestureCallbacks.onReactionsTap(MessageReactionsInfo(id: viewModel.message.id))
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
            HStack(spacing: 4) {
                ReadIndicatorView(
                    viewModel: ReadIndicatorViewModel(
                        isRead: viewModel.isRead,
                        isReadByAll: viewModel.isReadByAll,
                        localState: viewModel.sendingState
                    )
                )
                timeView
            }

        } else {

            HStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.author.name)
                        .font(Font.custom(size: 12, weight: .bold))
                        .lineLimit(1)
                        .foregroundColor(colorByString(viewModel.author.name))
                        .accessibilityIdentifier("MessageDateView")

                    timeView
                }
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
        Text(viewModel.time)
            .font(.footnote1)
            .foregroundColor(Color(.black).opacity(0.6))
    }

    private var avatarView: some View {
        Group {
            if !viewModel.isDirectMessageChat {
                VStack {
                    Spacer()
                    if viewModel.showAvatar {
                        AvatarView(
                            imageUrl: viewModel.author.imageUrl,
                            size: avatarSize
                        )
                    } else {
                        ZStack {
                            Color.clear
                                .frame(width: avatarSize)
                        }
                    }
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
                    id: UUID(),
                    name: "Ilon",
                    imageUrl: ImageURLExamples.portraitImageUrl
                ),
                isSentByCurrentUser: false,
                message: TextExamples.largeMessageText,
                quotedMessage: { Message(message: "Quoted Message")
                },
                reactions: [ReactionType(rawValue: "haha"): 1],
                isDeleted: false
            ),
            showsAllInfo: true,
            isLast: true,
            isDirectMessageChat: false
        ),
        width: UIScreen.main.bounds.width
    )
}
