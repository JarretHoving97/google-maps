//
//  CustomUIFactory+ViewFactory+Stream+Extension.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import SwiftUI
import Photos
import StreamChatSwiftUI
import StreamChat

extension CustomUIFactory: ViewFactory {

    public typealias MessageViewModifier = CustomMessageBubbleModifier

    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> CustomMessageBubbleModifier {
        CustomMessageBubbleModifier(
            message: messageModifierInfo.message,
            isFirst: messageModifierInfo.isFirst,
            injectedBackgroundColor: messageModifierInfo.injectedBackgroundColor,
            cornerRadius: messageModifierInfo.cornerRadius,
            forceLeftToRight: messageModifierInfo.forceLeftToRight
        )
    }

    // MARK: Channel-related Views

    public typealias ChannelListTopViewType = AmiChatTrialNoticeView

    public func makeChannelListTopView(
        searchText: Binding<String>
    ) -> AmiChatTrialNoticeView {
        AmiChatTrialNoticeView()
    }

    public typealias ChannelDestination = CustomChatChannelView<CustomUIFactory>

    public func makeChannelDestination() -> (ChannelSelectionInfo) -> ChannelDestination {
        { [unowned self] selectionInfo in
            return CustomChatChannelView(
                viewFactory: self,
                messageId: nil,
                channelController: chatClient.channelController(for: selectionInfo.channel.cid)
            )
        }
    }

    public typealias ChannelListItemType = CustomChatChannelNavigatableListItem<ChannelDestination>

    public func
    makeChannelListItem(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) -> ChannelListItemType {
        CustomChatChannelNavigatableListItem(
            channel: channel,
            channelName: channelName,
            avatar: avatar,
            onlineIndicatorShown: false,
            disabled: disabled,
            selectedChannel: selectedChannel,
            channelDestination: channelDestination,
            onItemTap: onItemTap,
            onLongPress: trailingSwipeLeftButtonTapped
        )
    }

    public typealias MessageListDateIndicatorViewType = CustomDateIndicatorView

    public func makeMessageListDateIndicator(date: Date) -> CustomDateIndicatorView {
        CustomDateIndicatorView(date: date)
    }

    public  typealias ChannelListDividerItem = EmptyView

    public func makeChannelListDividerItem() -> EmptyView {
        EmptyView()
    }

    public typealias NoChannels = CustomEmptyChannelsView

    public func makeNoChannelsView() -> CustomEmptyChannelsView {
        CustomEmptyChannelsView()
    }

    public func makeChannelListBackground(colors: ColorPalette) -> some View {
        Color.white
            .edgesIgnoringSafeArea(.bottom)
    }

    public typealias ChannelListSearchResultsViewType = CustomSearchResultsView<CustomUIFactory>

    public func makeSearchResultsView(
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping (ChatChannel) -> Bool,
        channelNaming: @escaping (ChatChannel) -> String,
        imageLoader: @escaping (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping (Int) -> Void
    ) -> CustomSearchResultsView<CustomUIFactory> {
        CustomSearchResultsView(
            factory: self,
            selectedChannel: selectedChannel,
            searchResults: searchResults,
            loadingSearchResults: loadingSearchResults,
            onlineIndicatorShown: onlineIndicatorShown,
            channelNaming: channelNaming,
            imageLoader: imageLoader,
            onSearchResultTap: onSearchResultTap,
            onItemAppear: onItemAppear
        )
    }

    public typealias ChannelListSearchResultItem = CustomSearchResultItem<ChannelDestination>

    public func makeChannelListSearchResultItem(
        searchResult: ChannelSelectionInfo,
        onlineIndicatorShown: Bool,
        channelName: String,
        avatar: UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination
    ) -> CustomSearchResultItem<ChannelDestination> {
        CustomSearchResultItem(
            searchResult: searchResult,
            onlineIndicatorShown: onlineIndicatorShown,
            channelName: channelName,
            avatar: avatar,
            onSearchResultTap: onSearchResultTap,
            channelDestination: channelDestination
        )
    }

    public func makeBottomReactionsView(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        CustomBottomReactionsView(
            message: message,
            showsAllInfo: showsAllInfo,
            onTap: onLongPress,
            onLongPress: onLongPress
        )
        .id(message.reactionScoresId)
    }

    public typealias LeadingComposerViewType = CustomAttachmentPickerTypeView

    public func makeLeadingComposerView(
        state: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) -> CustomAttachmentPickerTypeView {
        CustomAttachmentPickerTypeView(
            pickerTypeState: state,
            channelConfig: channelConfig
        )
    }

    public typealias ComposerInputViewType = CustomComposerInputContainerView<CustomUIFactory>

    public func makeComposerInputView(
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> CustomComposerInputContainerView<CustomUIFactory> {
        CustomComposerInputContainerView(
            factory: self,
            text: text,
            selectedRangeLocation: selectedRangeLocation,
            command: command,
            addedAssets: addedAssets,
            addedFileURLs: addedFileURLs,
            addedCustomAttachments: addedCustomAttachments,
            quotedMessage: quotedMessage,
            maxMessageLength: maxMessageLength,
            cooldownDuration: cooldownDuration,
            onCustomAttachmentTap: onCustomAttachmentTap,
            removeAttachmentWithId: removeAttachmentWithId,
            shouldScroll: shouldScroll
        )
    }

    public typealias TrailingComposerViewType = CustomTrailingComposerView

    public func makeTrailingComposerView(
        enabled: Bool,
        cooldownDuration: Int,
        onTap: @escaping () -> Void
    ) -> CustomTrailingComposerView {
        CustomTrailingComposerView(sendButtonEnabled: enabled, cooldownDuration: cooldownDuration, sendMessage: onTap)
    }

    public typealias AttachmentSourcePickerViewType = CustomAttachmentSourcePickerView

    public func makeAttachmentSourcePickerView(
        selected: AttachmentPickerState,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void
    ) -> CustomAttachmentSourcePickerView {
        CustomAttachmentSourcePickerView(
            selected: selected,
            onTap: onPickerStateChange
        )
    }

//    typealias AttachmentPickerViewType = CustomAttachmentPickerView
    public typealias RecordingView = CustomRecordingView

    public func makeComposerRecordingView(
        viewModel: MessageComposerViewModel,
        gestureLocation: CGPoint
    ) -> CustomRecordingView {
        CustomRecordingView(
            location: gestureLocation,
            audioRecordingInfo: viewModel.audioRecordingInfo,
            onMicTap: viewModel.stopRecording
        )
    }

    public typealias LockedView = CustomLockedView

    public func makeComposerRecordingLockedView(
        viewModel: MessageComposerViewModel
    ) -> CustomLockedView {
        CustomLockedView(viewModel: viewModel)
    }

    public typealias ComposerRecordingTipViewType = CustomRecordingTipView

    public func makeComposerRecordingTipView() -> CustomRecordingTipView {
        CustomRecordingTipView()
    }

    // MARK: Message-related Views

    public typealias MessageContainerViewType = CustomMessageContainerView<CustomUIFactory>

    public func makeMessageContainerView(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        showsAllInfo: Bool,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping (StreamChatSwiftUI.MessageDisplayInfo) -> Void,
        isLast: Bool
    ) -> CustomMessageContainerView<CustomUIFactory> {
        CustomMessageContainerView(
            factory: self,
            channel: channel,
            message: message,
            width: width,
            showsAllInfo: showsAllInfo,
            isInThread: isInThread,
            isLast: isLast,
            scrolledId: scrolledId,
            quotedMessage: quotedMessage,
            onLongPress: onLongPress
        )
    }

    public typealias MessageDateViewType = CustomMessageDateView

    public func makeMessageDateView(for message: ChatMessage) -> CustomMessageDateView {
        CustomMessageDateView(message: message)
    }

    public typealias MessageAuthorAndDateViewType = CustomMessageAuthorAndDateView

    public func makeMessageAuthorAndDateView(for message: ChatMessage) -> CustomMessageAuthorAndDateView {
        CustomMessageAuthorAndDateView(message: message)
    }

    public typealias DateIndicatorViewType = CustomDateIndicatorView

    public func makeDateIndicatorView(dateString: String) -> CustomDateIndicatorView {
        CustomDateIndicatorView(dateString: dateString)
    }

    public typealias MessageReadIndicatorViewType = CustomMessageReadIndicatorView

    public func makeMessageReadIndicatorView(
        channel: ChatChannel,
        message: ChatMessage
    ) -> CustomMessageReadIndicatorView {
        let isRead = channel.unreadCount == .noUnread
        let isReadByAll = message.readByCount >= channel.memberCount - 1

        return CustomMessageReadIndicatorView(
            isRead: isRead,
            isReadByAll: isReadByAll,
            localState: message.localState
        )
    }

    public typealias QuotedMessageHeaderViewType = EmptyView

    public func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
    ) -> EmptyView {
        EmptyView()
    }

    public typealias QuotedMessageViewType = CustomQuotedMessageViewContainer<CustomUIFactory>

    public func makeQuotedMessageView(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool,
        scrolledId: Binding<String?>
    ) -> CustomQuotedMessageViewContainer<CustomUIFactory> {
        CustomQuotedMessageViewContainer(
            factory: self,
            quotedMessage: quotedMessage,
            fillAvailableSpace: fillAvailableSpace,
            isInComposer: isInComposer,
            scrolledId: scrolledId
        )
    }

    public typealias VoiceRecordingViewType = CustomVoiceRecordingContainerView<CustomUIFactory>

    public func makeVoiceRecordingView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> CustomVoiceRecordingContainerView<CustomUIFactory> {
        CustomVoiceRecordingContainerView(
            factory: self,
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }

    public typealias SystemMessageViewType = CustomSystemMessageView

    public func makeSystemMessageView(message: ChatMessage) -> CustomSystemMessageView {
        CustomSystemMessageView(message: message)
    }

    public typealias ReactionsOverlayViewType = CustomReactionsOverlayView<CustomUIFactory>

    public func makeReactionsOverlayView(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) -> CustomReactionsOverlayView<CustomUIFactory> {
        CustomReactionsOverlayView(
            factory: self,
            channel: channel,
            currentSnapshot: currentSnapshot,
            messageDisplayInfo: messageDisplayInfo,
            onBackgroundTap: onBackgroundTap,
            onActionExecuted: onActionExecuted
        )
    }

    public func supportedMessageActions(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        MessageAction.customActions(
            factory: self,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
    }

    public typealias MessageActionsViewType = CustomMessageActionsView

    public func makeMessageActionsView(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> CustomMessageActionsView {
        let messageActions = supportedMessageActions(
            for: message,
            channel: channel,
            onFinish: onFinish,
            onError: onError
        )

        return CustomMessageActionsView(for: message, messageActions: messageActions)
    }

    public func supportedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        ChannelAction.customActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
    }

    public typealias MoreActionsView = CustomMoreChannelActionsContainerView<CustomUIFactory>

    public func makeMoreChannelActionsView(
        for channel: ChatChannel,
        swipedChannelId: Binding<String?>,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> CustomMoreChannelActionsContainerView<CustomUIFactory> {
        CustomMoreChannelActionsContainerView(
            factory: self,
            channel: channel,
            channelActions: supportedMoreChannelActions(
                for: channel,
                onDismiss: onDismiss,
                onError: onError
            ),
            onDismiss: onDismiss
        )
    }

    public typealias DeletedMessageViewType = DeletedMessageView

    public func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> DeletedMessageViewType {
        DeletedMessageView(
            message: message,
            isFirst: isFirst
        )
    }

    public typealias NewMessagesIndicatorViewType = CustomNewMessagesIndicatorView

    public func makeNewMessagesIndicatorView(
        newMessagesStartId: Binding<String?>,
        count: Int
    ) -> CustomNewMessagesIndicatorView {
        CustomNewMessagesIndicatorView(
            newMessagesStartId: newMessagesStartId,
            count: count
        )
    }

    public typealias JumpToUnreadButtonType = EmptyView

    public func makeJumpToUnreadButton(
        channel: ChatChannel,
        onJumpToMessage: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> EmptyView {
        EmptyView()
    }

    public typealias ScrollToBottomButtonType = CustomScrollToBottomButton

    public func makeScrollToBottomButton(
        unreadCount: Int,
        onScrollToBottom: @escaping () -> Void
    ) -> CustomScrollToBottomButton {
        CustomScrollToBottomButton(
            unreadCount: unreadCount,
            onScrollToBottom: onScrollToBottom
        )
    }

    public typealias EmptyMessagesViewType = CustomEmptyMessagesView

    public func makeEmptyMessagesView(
        for channel: ChatChannel,
        colors: ColorPalette
    ) -> CustomEmptyMessagesView {
        CustomEmptyMessagesView(channel: channel)
    }
}

extension ViewFactory {

    public func makeChannelHeaderViewModifier(for channel: ChatChannel) -> CustomChannelHeaderView<Self> {
        CustomChannelHeaderView(viewFactory: self, channel: channel)
    }
}
