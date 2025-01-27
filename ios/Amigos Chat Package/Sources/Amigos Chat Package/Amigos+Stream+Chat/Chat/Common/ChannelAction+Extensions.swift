import StreamChat
import StreamChatSwiftUI

extension ChannelAction {

    /// Returns the channel actions.
    public static func customActions(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
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
                    onDismiss: onDismiss,
                    onError: onError
                )

                actions.append(unmuteAction)
            } else {
                let muteAction = muteAction(
                    for: channel,
                    chatClient: chatClient,
                    onDismiss: onDismiss,
                    onError: onError
                )

                actions.append(muteAction)
            }
        }

        if !channel.isDirectMessageChannel {
            let memberRole = channel.membership?.memberRole
            let hasCapability = channel.ownCapabilities.contains(.leaveChannel)
            let isActiveActivity = channel.extraData["activityIsActive"]?.numberValue == 1

            let isAllowedToLeaveChannel =
                hasCapability &&
                (

                    memberRole == .channelMember ||
                    memberRole == .coOrganizer ||
                    (channel.isCurrentUserOrganizer && isActiveActivity)
                )

            if isAllowedToLeaveChannel {
                let leaveAction = leaveChat(
                    for: channel,
                    chatClient: chatClient,
                    onDismiss: onDismiss,
                    onError: onError
                )

                actions.append(leaveAction)
            }
        } else {
            let archiveAction = archiveChat(
                for: channel,
                chatClient: chatClient,
                onDismiss: onDismiss,
                onError: onError
            )

            actions.append(archiveAction)
        }

        return actions
    }

    private static func deleteChat(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.deleteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
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
            iconName: "chevron.right",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    private static func leaveChat(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
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
            iconName: "chevron.right",
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
            iconName: "chevron.right",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    private static func muteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.muteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }

        return ChannelAction(
            title: tr("custom.channel.action.mute.title"),
            iconName: "chevron.right",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private static func unmuteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let action = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.unmuteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }

        return ChannelAction(
            title: tr("custom.channel.action.unmute.title"),
            iconName: "chevron.right",
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

        if channel.isDirectMessageChannel, let userId = otherUser?.id {
            let profileAction = ChannelAction(
                title: tr("custom.channel.action.profile.title"),
                iconName: "chevron.right",
                action: { RouteController.routeAction?(RouteInfo(route:  .profileRoute(id: userId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            let inviteAction = ChannelAction(
                title: tr("custom.channel.action.invite.title"),
                iconName: "chevron.right",
                action: {RouteController.routeAction?(RouteInfo(route:  .profileInviteRoute(id: userId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            return [profileAction, inviteAction]
        }

        if !channel.isDirectMessageChannel {
            let activityId = channel.cid.id

            let viewAction = ChannelAction(
                title: tr("custom.channel.action.activity.title"),
                iconName: "chevron.right",
                action: { RouteController.routeAction?(RouteInfo(route: .activityRoute(id: activityId), dismiss: true))},
                confirmationPopup: nil,
                isDestructive: false
            )

            var organizerActions = [viewAction]

            if channel.extraData["active"]?.numberValue == 1 {
                if channel.membership?.memberRole == MemberRole.coOrganizer || channel.isCurrentUserOrganizer {
                    let inviteAction = ChannelAction(
                        title: tr("custom.channel.action.inviteAmigos.title"),
                        iconName: "chevron.right",
                        action: { RouteController.routeAction?(RouteInfo(route: .inviteToActivityRoute(id: activityId), dismiss: true))},
                        confirmationPopup: nil,
                        isDestructive: false
                    )

                    organizerActions.append(inviteAction)

                    let manageAction = ChannelAction(
                        title: tr("custom.channel.action.manageParticipants.title"),
                        iconName: "chevron.right",
                        action: { RouteController.routeAction?(RouteInfo(route: .manageActivityParticipantsRoute(id: activityId), dismiss: true))},
                        confirmationPopup: nil,
                        isDestructive: false
                    )

                    organizerActions.append(manageAction)
                }
            }

            return organizerActions
        }

        return nil
    }
}
