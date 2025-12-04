import StreamChat
import StreamChatSwiftUI

public struct ChannelActionCallbacks {
    let onDismiss: () -> Void
    let onError: (Error) -> Void
    let onClose: () -> Void

    init(onDismiss: @escaping () -> Void, onError: @escaping (Error) -> Void, onClose: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.onError = onError
        self.onClose = onClose
    }

    init(from actions: ChannelActionsView.CallBackActions) {
        self.onError = actions.onError
        self.onClose = actions.onClose
        self.onDismiss = actions.onDissmiss
    }
}

extension ChannelAction {

    /// Returns the channel actions.
    public static func customActions(
        for channel: ChatChannel,
        chatClient: ChatClient,
        callbacks: ChannelActionCallbacks

    ) -> [ChannelAction] {
        var actions = [ChannelAction]()

        if let navigateActions = navigateActions(for: channel, chatClient: chatClient) {
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
                    callbacks.onClose()
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
                    // onDismiss() instead of onClose() for now
                    // How Stream's API works, for toggling notifications we probably need a new instance of `ChatChannel`
                    // which we have if we just leave the channel
                    callbacks.onDismiss()
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
                    // onDismiss() instead of onClose() for now
                    // How Stream's API works, for toggling notifications we probably need a new instance of `ChatChannel`
                    // which we have if we just leave the channel
                    callbacks.onDismiss()
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

    static func navigateActions(
        for channel: ChatChannel,
        chatClient: ChatClient
    ) -> [ChannelAction]? {
        let otherUser = channel.lastActiveMembers
            .first(where: { $0.id != chatClient.currentUserId })

        if case .standard = channel.relatedConceptType, let userId = otherUser?.id {
            let profileAction = ChannelAction(
                title: tr("custom.channel.action.profile.title"),
                iconName: "chevronRight",
                action: { RouteController.routeAction?(RouteInfo(route: .profileRoute(id: userId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            let inviteAction = ChannelAction(
                title: tr("custom.channel.action.invite.title"),
                iconName: "chevronRight",
                action: {RouteController.routeAction?(RouteInfo(route: .profileInviteRoute(id: userId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            return [profileAction, inviteAction]
        }

        if case .activity(let activityId) = channel.relatedConceptType {
            let viewAction = ChannelAction(
                title: tr("custom.channel.action.activity.title"),
                iconName: "chevronRight",
                action: { RouteController.routeAction?(RouteInfo(route: .activityRoute(id: activityId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            var organizerActions = [viewAction]

            if channel.extraData["active"]?.numberValue == 1 {

                if channel.membership?.memberRole == MemberRole.coOrganizer || channel.isCurrentUserOrganizer {
                    let inviteAction = ChannelAction(
                        title: tr("custom.channel.action.inviteAmigos.title"),
                        iconName: "chevronRight",
                        action: { RouteController.routeAction?(RouteInfo(route: .inviteToActivityRoute(id: activityId), dismiss: true))},
                        confirmationPopup: nil,
                        isDestructive: false
                    )

                    organizerActions.append(inviteAction)

                    let manageAction = ChannelAction(
                        title: tr("custom.channel.action.manageParticipants.title"),
                        iconName: "chevronRight",
                        action: { RouteController.routeAction?(RouteInfo(route: .manageActivityParticipantsRoute(id: activityId), dismiss: true))},
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
                action: { RouteController.routeAction?(RouteInfo(route: .communityRoute(id: id), dismiss: true))},
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
//                    action: {
//                        RouteController.routeAction?(
//                            RouteInfo(route: .communityActivityInviteRoute(id: id), dismiss: true)
//                        )
//                    },
//                    confirmationPopup: nil,
//                    isDestructive: false
//                )
//
//                communityActions.append(inviteViewAction)

                let communityParticipantsAction = ChannelAction(
                    title: tr("custom.channel.action.manageParticipants.title"),
                    iconName: "chevronRight",
                    action: {
                        RouteController.routeAction?(
                            RouteInfo(route: .manageCommunityParticipantsRoute(id: id), dismiss: true)
                        )
                    },
                    confirmationPopup: nil,
                    isDestructive: false
                )

                communityActions.append(communityParticipantsAction)
            }

            return communityActions
        }

        return nil
    }
}
