//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

struct CustomChatChannelHeaderMoreButtonView: View {
    
    @EnvironmentObject private var viewModel: ChatChannelListViewModel
    
    public let channel: ChatChannel
    
    var body: some View {
        HeaderButtonView(iconSystemName: "ellipsis", leading: false) {
            resignFirstResponder()
            
            withAnimation {
                viewModel.onMoreTapped(channel: channel)
            }
        }
    }
}

/// The default channel header.
public struct CustomChatChannelHeader<Factory: ViewFactory>: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
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
    
    @State var mood: Mood? = nil

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

        updateAppearance()
    }
    
    func updateAppearance() {
        // MARK: Navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.white)
        navigationBarAppearance.shadowColor = UIColor.clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                
        // MARK: Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.white)
        tabBarAppearance.shadowColor = UIColor.clear
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    func onTapPrincipalHeader() {
        var route: String?
        
        if channel.isDirectMessageChannel, let userId = otherUser?.id {
            route = "/profile/\(userId)"
        } else if !channel.isDirectMessageChannel {
            let activityId = channel.cid.id
            route = "/activity/\(activityId)"
        }
        
        if let route {
            ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: route, dismiss: true)
        }
    }
    
    func setMood() {
        if !channel.isSupportChatChannel && channel.isDirectMessageChannel {
            Task {
                mood = await otherUser?.getMood()
            }
        }
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 20) {
                HStack {
                    HeaderButtonView {
                        if chatViewModel.isChannelView {
                            ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true)
                        } else {
                            ExtendedStreamPlugin.shared.notifyNavigateBackToListeners()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                ZStack {
                    Button {
                        resignFirstResponder()
                        onTapPrincipalHeader()
                    } label: {
                        HStack(spacing: 8) {
                             if channel.isDirectMessageChannel {
                                CustomChannelAvatarView(
                                    avatar: headerImage,
                                    showOnlineIndicator: false,
                                    size: CGSize(width: 32, height: 32)
                                )
                                .allowsHitTesting(false)
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("ChannelAvatarView")
                             }
                                 
                            VStack(alignment: .leading, spacing: 0) {
                                CustomChannelTitleView(channel: channel, shouldShowTypingIndicator: shouldShowTypingIndicator)
                                 
                                if !shouldShowTypingIndicator {
                                    if let text = mood?.title {
                                         Text(text)
                                             .lineLimit(1)
                                             .font(fonts.caption2)
                                             .foregroundColor((mood?.isActive ?? false) ? Color("Grey Dark") : Color("Grey"))
                                     }
                                }
                             }
                            .frame(maxWidth: 200)
                        }
                    }
                }
                .onAppear(perform: setMood)
            }
            .padding(.leading, -14)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 8) {
                if !channel.isSupportChatChannel && channel.isDirectMessageChannel, let userId = otherUser?.id {
                    AmiIconButton(action: {
                        let route = "/profile/\(userId)/invite"
                        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: route, dismiss: true)
                    }) {
                        Image("Plus")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 2)
                    
                    Divider()
                        .frame(minWidth: 1, idealWidth: 1, maxHeight: .infinity)
                        .overlay(Color("Grey Light"))
                }
                
                CustomChatChannelHeaderMoreButtonView(channel: channel)
            }
            .padding(.trailing, -14)
        }
    }
}

/// The default header modifier.
public struct CustomChatChannelHeaderViewModifier<Factory: ViewFactory>: ChatChannelHeaderViewModifier {
    
    @ObservedObject private var channelHeaderLoader = InjectedValues[\.utils].channelHeaderLoader
    @State private var isActive: Bool = false

    public var viewFactory: Factory
    public var channel: ChatChannel
    
    public init(viewFactory: Factory, channel: ChatChannel) {
        self.viewFactory = viewFactory
        self.channel = channel
    }

    public func body(content: Content) -> some View {
        content.toolbar {
            CustomChatChannelHeader(
                viewFactory: viewFactory,
                channel: channel,
                headerImage: channelHeaderLoader.image(for: channel),
                isActive: $isActive
            )
        }.navigationBarBackButtonHidden(true)
    }
}

struct CustomChannelTitleView: View {

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
        VStack(alignment: .leading, spacing: 0) {
            Text(channelNamer(channel, currentUserId) ?? "")
                .font(fonts.headline)
                .foregroundColor(Color(colors.text))
                .multilineTextAlignment(.leading)
                .accessibilityIdentifier("chatName")
                .truncationMode(.tail)

            if shouldShowTypingIndicator {
                Text(channel.typingIndicatorString(currentUserId: currentUserId))
                    .lineLimit(1)
                    .font(fonts.caption2)
                    .foregroundColor(Color(colors.subtitleText))
            }
        }
    }
}
