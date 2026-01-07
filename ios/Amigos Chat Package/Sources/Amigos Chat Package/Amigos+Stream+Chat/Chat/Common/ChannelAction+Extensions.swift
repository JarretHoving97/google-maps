import StreamChat
import StreamChatSwiftUI

public struct ChannelActionCallbacks {

    struct Info {
        let channel: ChatChannel
    }

    let onDismiss: () -> Void
    let onError: (Error) -> Void
    let onClose: (Info?) -> Void

    init(onDismiss: @escaping () -> Void, onError: @escaping (Error) -> Void, onClose: @escaping (Info?) -> Void) {
        self.onDismiss = onDismiss
        self.onError = onError
        self.onClose = onClose
    }

    init(from actions: ChannelActionsView.CallBackActions) {
        self.onError = actions.onError
        self.onClose = actions.onClose
        self.onDismiss = actions.onDismiss
    }
}

extension ChannelAction {

    /// Returns the channel actions.
    @MainActor public static func customActions(
        for channel: ChatChannel,
        chatClient: ChatClient,
        callbacks: ChannelActionCallbacks,
        router: Router?

    ) -> [ChannelAction] {
        var actions = [ChannelAction]()

        if let navigateActions = navigateActions(for: channel, chatClient: chatClient, router: router) {
            actions += navigateActions
        }

        if channel.config.mutesEnabled && channel.ownCapabilities.contains(.muteChannel) {
            if channel.isMuted {
                let unmuteAction = unmuteAction(
                    for: channel,
                    chatClient: chatClient,
                    callbacks: callbacks
                )
                actions.append(unmuteAction)
            } else {
                let muteAction = muteAction(
                    for: channel,
                    chatClient: chatClient,
                    callbacks: callbacks
                )

                actions.append(muteAction)
            }
        }

        if case .activity = channel.relatedConceptType {
            let memberRole = channel.membership?.memberRole
            let hasCapability = channel.ownCapabilities.contains(.leaveChannel)
            let isActiveActivity = channel.extraData["activityIsActive"]?.numberValue == 1

            let isAllowedToLeaveChannel =
                hasCapability &&
                (
                    // participants and co-hosts always see the leave button
                    memberRole == .channelMember ||
                    memberRole == .coOrganizer ||
                    // hosts will only see the button if the activity is deleted/expired
                    (channel.isCurrentUserOrganizer && !isActiveActivity)
                )

            if isAllowedToLeaveChannel {
                let leaveAction = leaveChat(
                    for: channel,
                    chatClient: chatClient,
                    onDismiss: callbacks.onDismiss,
                    onError: callbacks.onError
                )

                actions.append(leaveAction)
            }
        } else if case .standard = channel.relatedConceptType {
            let archiveAction = archiveChat(
                for: channel,
                chatClient: chatClient,
                onDismiss: callbacks.onDismiss,
                onError: callbacks.onError,
            )

            actions.append(archiveAction)
        }

        return actions
    }

    private static func deleteChat(
        for channel: ChatChannel,
        chatClient: ChatClient,
        callbacks: ChannelActionCallbacks
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.deleteChannel { error in
                if let error = error {
                    callbacks.onError(error)
                } else {
                    callbacks.onClose(nil)
                }
            }
        }

        let confirmationPopup = ConfirmationPopup(
            title: tr("custom.channel.action.delete.title"),
            message: tr("custom.channel.action.delete.confirmation-body"),
            buttonTitle: tr("custom.channel.action.delete.confirmation-confirm")
        )

        return ChannelAction(
            title: tr("custom.channel.action.delete.title"),
            iconName: "binIcon",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    private static func leaveChat(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void,
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)

            if let userId = chatClient.currentUserId {
                controller.removeMembers(userIds: [userId]) { error in
                    if let error = error {
                        onError(error)
                    } else {
                        onDismiss()
                    }
                }
            }
        }

        let confirmationPopup = ConfirmationPopup(
            title: tr("custom.channel.action.leave.title"),
            message: tr("custom.channel.action.leave.confirmation-body"),
            buttonTitle: tr("custom.channel.action.leave.confirmation-confirm")
        )

        return ChannelAction(
            title: tr("custom.channel.action.leave.title"),
            iconName: "chevronRight",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    private static func archiveChat(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)

            controller.hideChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }

        let confirmationPopup = ConfirmationPopup(
            title: tr("custom.channel.action.archive.title"),
            message: tr("custom.channel.action.archive.confirmation-body"),
            buttonTitle: tr("custom.channel.action.archive.confirmation-confirm")
        )

        return ChannelAction(
            title: tr("custom.channel.action.archive.title"),
            iconName: "binIcon",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    private static func muteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        callbacks: ChannelActionCallbacks
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.muteChannel { error in
                if let error = error {
                    callbacks.onError(error)
                } else {
                    Self.notifyClose(using: chatClient, channelId: channel.cid, closeAction: callbacks.onClose)
                }
            }
        }

        return ChannelAction(
            title: tr("custom.channel.action.mute.title"),
            iconName: "notificationOn",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private static func unmuteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        callbacks: ChannelActionCallbacks
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.unmuteChannel { error in
                if let error = error {
                    callbacks.onError(error)
                } else {
                    Self.notifyClose(using: chatClient, channelId: channel.cid, closeAction: callbacks.onClose)
                }
            }
        }

        return ChannelAction(
            title: tr("custom.channel.action.unmute.title"),
            iconName: "notificationOff",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    @MainActor
    static func navigateActions(
        for channel: ChatChannel,
        chatClient: ChatClient,
        router: Router?
    ) -> [ChannelAction]? {
        let otherUser = channel.lastActiveMembers
            .first(where: { $0.id != chatClient.currentUserId })

        if case .standard = channel.relatedConceptType, let userId = otherUser?.id {
            let profileAction = ChannelAction(
                title: tr("custom.channel.action.profile.title"),
                iconName: "chevronRight",
                action: { router?.push(.client(.profileRoute(id: userId))) },
                confirmationPopup: nil,
                isDestructive: false
            )

            let inviteAction = ChannelAction(
                title: tr("custom.channel.action.invite.title"),
                iconName: "chevronRight",
                action: { router?.push(.client(.profileInviteRoute(id: userId))) },
                confirmationPopup: nil,
                isDestructive: false
            )

            return [profileAction, inviteAction]
        }

        if case .activity(let activityId) = channel.relatedConceptType {
            let viewAction = ChannelAction(
                title: tr("custom.channel.action.activity.title"),
                iconName: "chevronRight",
                action: { router?.push(.client(.activityRoute(id: activityId))) },
                confirmationPopup: nil,
                isDestructive: false
            )

            var organizerActions = [viewAction]

            if channel.extraData["active"]?.numberValue == 1 {

                if channel.membership?.memberRole == MemberRole.coOrganizer || channel.isCurrentUserOrganizer {
                    let inviteAction = ChannelAction(
                        title: tr("custom.channel.action.inviteAmigos.title"),
                        iconName: "chevronRight",
                        action: { router?.push(.client(.inviteToActivityRoute(id: activityId))) },
                        confirmationPopup: nil,
                        isDestructive: false
                    )

                    organizerActions.append(inviteAction)

                    let manageAction = ChannelAction(
                        title: tr("custom.channel.action.manageParticipants.title"),
                        iconName: "chevronRight",
                        action: { router?.push(.client(.manageActivityParticipantsRoute(id: activityId))) },
                        confirmationPopup: nil,
                        isDestructive: false
                    )

                    organizerActions.append(manageAction)
                }
            }

            return organizerActions
        }

        if case .community(let id) = channel.relatedConceptType {

            var communityActions: [ChannelAction] = []

            let viewAction = ChannelAction(
                title: Localized.ChatChannel.viewCommunityActionLabel,
                iconName: "chevronRight",
                action: { router?.push(.client(.communityRoute(id: id))) },
                confirmationPopup: nil,
                isDestructive: false
            )

            communityActions.append(viewAction)

            let userMembershipStatus: MemberRole? = channel.membership?.memberRole

            if userMembershipStatus == .organizer || userMembershipStatus == .coOrganizer {

//                MARK: Comment this out for now

//                let inviteViewAction = ChannelAction(
//                    title: tr("custom.channel.action.inviteAmigos.title"),
//                    iconName:  "chevronRight",
//                    action: { router?.push(.client(.communityActivityInviteRoute(id: id))) },
//                    confirmationPopup: nil,
//                    isDestructive: false
//                )
//
//                communityActions.append(inviteViewAction)
//
                let communityParticipantsAction = ChannelAction(
                    title: tr("custom.channel.action.manageParticipants.title"),
                    iconName: "chevronRight",
                    action: { router?.push(.client(.manageCommunityParticipantsRoute(id: id))) },
                    confirmationPopup: nil,
                    isDestructive: false
                )

                communityActions.append(communityParticipantsAction)
            }

            return communityActions
        }

        return nil
    }

    private static func notifyClose(
        using: ChatClient,
        channelId: ChannelId,
        closeAction: @escaping (ChannelActionCallbacks.Info?) -> Void
    ) {
        if let channel = using.channelController(for: channelId).channel {
            closeAction(ChannelActionCallbacks.Info(channel: channel))
        }
        closeAction(nil)
    }
}
