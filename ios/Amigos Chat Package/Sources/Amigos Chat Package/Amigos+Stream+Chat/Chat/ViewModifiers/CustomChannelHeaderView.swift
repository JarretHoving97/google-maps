//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

public typealias onMoreTappedAction = (() -> Void)

/// The default channel header.
public struct CustomChatChannelHeader<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient
    @Injected(\.chatRouter) private var router
    @Environment(\.presentationMode) var presentationMode

    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }

    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(currentUserId: currentUserId).isEmpty
        && utils.messageListConfig.typingIndicatorPlacement == .navigationBar
        && channel.config.typingEventsEnabled
    }

    private var otherUser: ChatChannelMember? {
        channel.lastActiveMembers
            .first(where: { $0.id != currentUserId })
    }

    public var viewFactory: Factory
    public var channel: ChatChannel
    public var headerImage: UIImage

    @Binding public var isActive: Bool
    @State var mood: Mood?

    public init(
        viewFactory: Factory,
        channel: ChatChannel,
        headerImage: UIImage,
        isActive: Binding<Bool>
    ) {
        self.viewFactory = viewFactory
        self.channel = channel
        self.headerImage = headerImage
        _isActive = isActive

    }

    func onTapPrincipalHeader() {

        var route: ClientRoute?

        if case .activity(let activityId) = channel.relatedConceptType {
            route = .activityRoute(id: activityId)
        }

        if case .standard = channel.relatedConceptType, let userId = otherUser?.id {
            route = .profileRoute(id: userId)
        }

        if case .community(id: let id) = channel.relatedConceptType {
            route = .communityRoute(id: id)
        }

        if let route {
            router?.push(.client(route))
        }
    }

    private func setMood() async {
        if !channel.isSupportChatChannel && channel.isDirectMessageChannel {
            mood = await otherUser?.getMood()
        }
    }

    var avatarImage: URL? {
        return otherUser?.imageURL
    }

    public var body: some View {

        Button {
            onTapPrincipalHeader()
        } label: {
            HStack(alignment: .center, spacing: 8) {

                if channel.isDirectMessageChannel {
                    AvatarView(
                        imageUrl: avatarImage,
                        size: 32
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("ChannelAvatarView")
                }

                VStack(alignment: .leading, spacing: 0) {
                    CustomChannelNameView(
                        channel: channel,
                        shouldShowTypingIndicator: shouldShowTypingIndicator
                    )
                    if shouldShowTypingIndicator {
                        Text(channel.typingIndicatorString(currentUserId: currentUserId))
                            .lineLimit(1)
                            .font(fonts.caption2)
                            .foregroundColor(Color(colors.subtitleText))
                    } else if let text = mood?.title {
                        Text(text)
                            .lineLimit(1)
                            .font(fonts.caption2)
                            .foregroundColor((mood?.isActive ?? false) ? Color("Grey Dark") : Color("Grey"))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 52) // fixed height so it always stays centered
        .task {
            // delay to prevent content shifting.
            try? await Task.sleep(nanoseconds: 700_000_000)
            await setMood()
        }
    }
}

/// The default header modifier.
public struct CustomChannelHeaderView<Factory: ViewFactory>: View {

    @ObservedObject private var channelHeaderLoader = InjectedValues[\.utils].channelHeaderLoader
    @State private var isActive: Bool = false

    public var viewFactory: Factory
    public var channel: ChatChannel

    public init(
        viewFactory: Factory,
        channel: ChatChannel,
    ) {
        self.viewFactory = viewFactory
        self.channel = channel
    }

    public var body: some View {
        CustomChatChannelHeader(
            viewFactory: viewFactory,
            channel: channel,
            headerImage: channelHeaderLoader.image(for: channel),
            isActive: $isActive
        )
    }
}

struct CustomChannelNameView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient

    var channel: ChatChannel
    var shouldShowTypingIndicator: Bool

    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }

    private var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }

    var body: some View {
        Text(channelNamer(channel, currentUserId) ?? "")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(fonts.headline)
            .foregroundColor(Color(colors.text))
            .multilineTextAlignment(.leading)
            .accessibilityIdentifier("chatName")
            .truncationMode(.tail)

    }
}

struct CustomChannelHeaderModifier: ViewModifier {
    let channel: ChatChannel?
    let disabled: Bool

    func body(content: Content) -> some View {
        Group {
            if let channel {
                if #available(iOS 26.0, *) {
                    content.toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CustomChannelHeaderView(
                                viewFactory: CustomUIFactory(),
                                channel: channel
                            )
                            .disabled(disabled)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                } else {
                    content.toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CustomChannelHeaderView(
                                viewFactory: CustomUIFactory(),
                                channel: channel
                            )
                        }
                    }
                }
            }
        }
    }
}

extension View {

    func chatChannelHeader(channel: ChatChannel?, disabled: Bool = false) -> some View {
        modifier(CustomChannelHeaderModifier(channel: channel, disabled: disabled))
    }
}
