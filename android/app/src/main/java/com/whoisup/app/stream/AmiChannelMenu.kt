package com.whoisup.app.stream

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.components.AmiButtonLabel
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.TextColor
import com.whoisup.app.stream.extensions.AmiParticipantRole
import com.whoisup.app.stream.extensions.amiParticipantRole
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.client.extensions.isMutedFor
import io.getstream.chat.android.compose.ui.components.SimpleDialog
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.models.User

@Composable
fun AmiChannelMenu(
    singleChannelViewModel: SingleChannelViewModel,
    currentUser: User?,
    onBackClick: (() -> Unit)? = null,
) {
    val visible = singleChannelViewModel.selectedChannel != null

    AmiSimpleMenu(
        visible = visible,
        onDismiss = remember(singleChannelViewModel) { { singleChannelViewModel.closeModal() } }
    ) {
        if (visible) {
            val channelOptions = channelOptions(selectedChannel = singleChannelViewModel.selectedChannel, currentUser = currentUser)

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                channelOptions.forEach { option ->
                    key(option.action) {
                        AmiButtonLabel(
                            title = option.title,
                            iconId = option.iconId,
                            textColor = option.textColor,
                            onClick = {
                                option.action?.let {
                                    singleChannelViewModel.performChannelAction(it)
                                }

                                option.callback?.let {
                                    singleChannelViewModel.closeModal()
                                    it()
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    val activeAction = singleChannelViewModel.activeAction

    if (activeAction is LeaveChannel) {
        SimpleDialog(
            modifier = Modifier.padding(16.dp),
            title = stringResource(id = R.string.custom_channel_action_leave_title),
            message = stringResource(id = R.string.custom_channel_action_leave_confirmation_body),
            // confirm = stringResource(id = R.string.custom_channel_action_leave_confirmation_confirm),
            onPositiveAction = remember(singleChannelViewModel) {
                {
                    singleChannelViewModel.leaveChannel(activeAction.channel)

                    // Then navigate away from this view
                    onBackClick?.invoke()
                }
            },
            onDismiss = remember(singleChannelViewModel) { { singleChannelViewModel.dismissActiveAction() } },
        )
    } else if (activeAction is HideChannel) {
        SimpleDialog(
            modifier = Modifier.padding(16.dp),
            title = stringResource(id = R.string.custom_channel_action_archive_title),
            message = stringResource(id = R.string.custom_channel_action_archive_confirmation_body),
            // confirm = stringResource(id = R.string.custom_channel_action_archive_confirmation_confirm),
            onPositiveAction = remember(singleChannelViewModel) {
                {
                    singleChannelViewModel.hideChannel(activeAction.channel)

                    // Then navigate away from this view
                    onBackClick?.invoke()
                }
            },
            onDismiss = remember(singleChannelViewModel) { { singleChannelViewModel.dismissActiveAction() } },
        )
    }
}

class SingleChannelViewModel : ViewModel() {
    private val chatClient = ChatClient.instance()

    private var _selectedChannel: MutableState<Channel?> = mutableStateOf(null)

    val selectedChannel
        get() = _selectedChannel.value

    var activeAction: ChannelAction? by mutableStateOf(null)
        private set

    fun openModal(channel: Channel) {
        _selectedChannel.value = channel
    }

    fun closeModal() {
        _selectedChannel.value = null
    }

    fun dismissActiveAction() {
        activeAction = null
    }

    private fun muteChannel(channel: Channel) {
        chatClient.muteChannel(channel.type, channel.id).enqueue()
    }

    private fun unmuteChannel(channel: Channel) {
        chatClient.unmuteChannel(channel.type, channel.id).enqueue()
    }

    fun leaveChannel(channel: Channel) {
        dismissActiveAction()
        closeModal()

        chatClient.clientState.user.value?.let { user ->
            chatClient.channel(channel.type, channel.id).removeMembers(listOf(user.id)).enqueue()
        }
    }

    fun hideChannel(channel: Channel) {
        dismissActiveAction()
        closeModal()

        chatClient.hideChannel(channel.type, channel.id).enqueue()
    }

    fun performChannelAction(action: ChannelAction) {
        when (action) {
            is MuteChannel -> muteChannel(action.channel)
            is UnmuteChannel -> unmuteChannel(action.channel)
            else -> activeAction = action
        }
    }
}

/**
 * Represents the list of actions users can take with selected channels.
 *
 * @property channel The selected channel.
 */
sealed class ChannelAction {
    abstract val channel: Channel
}

/**
 * Mutes the channel.
 */
data class MuteChannel(override val channel: Channel) : ChannelAction()

/**
 * Unmutes the channel.
 */
data class UnmuteChannel(override val channel: Channel) : ChannelAction()

/**
 * Shows a dialog to leave the channel.
 */
data class LeaveChannel(override val channel: Channel) : ChannelAction()

/**
 * Shows a dialog to archive/hide the conversation, if we have the permission.
 */
data class HideChannel(override val channel: Channel) : ChannelAction()

internal  class ChannelOptionItemState(
    val title: String,
    @DrawableRes val iconId: Int = R.drawable.angle_right,
    val textColor: TextColor? = null,
    val action: ChannelAction? = null,
    val callback: (() -> Unit)? = null
)

@Composable
internal fun channelOptions(
    selectedChannel: Channel?,
    currentUser: User?
): List<ChannelOptionItemState> {
    if (selectedChannel == null) {
        return listOf()
    }

    val options: MutableList<ChannelOptionItemState> = mutableListOf()

    val isMuted = currentUser?.let { selectedChannel.isMutedFor(it) } ?: false

    val myMember = selectedChannel.members.firstOrNull {
        it.user.id == currentUser?.id
    }

    val isMainHost =
        selectedChannel.createdBy.id === currentUser?.id || // @TODO: this line should eventually be removed
        myMember?.amiParticipantRole == AmiParticipantRole.Organizer

    val otherUser = if (selectedChannel.isDirectMessageChannel()) {
        selectedChannel.members.firstOrNull {
            it.user.id != currentUser?.id
        }?.user
    } else {
        null
    }

    val activityIsActive = selectedChannel.extraData["activityIsActive"] as? Int ?: 1

    // START: navigation actions

    if (otherUser != null) {
        options += ChannelOptionItemState(
            title = stringResource(id = R.string.custom_channel_action_profile_title),
            callback = {
                val route = "/profile/${otherUser.id}"
                ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
            }
        )

        if (!otherUser.isSupportTeamMember) {
            options += ChannelOptionItemState(
                title = stringResource(id = R.string.custom_channel_action_invite_title),
                callback = {
                    val route = "/profile/${otherUser.id}/invite"
                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                }
            )
        }
    }

    if (!selectedChannel.isDirectMessageChannel()) {
        options += ChannelOptionItemState(
            title = stringResource(id = R.string.custom_channel_action_activity_title),
            callback = {
                val route = "/activity/${selectedChannel.id}"
                ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
            }
        )

        if (
            isMainHost ||
            myMember?.amiParticipantRole == AmiParticipantRole.PseudoOrganizer
        ) {
            if (activityIsActive == 1) {
                options += ChannelOptionItemState(
                    title = stringResource(id = R.string.custom_channel_action_inviteAmigos_title),
                    callback = {
                        val route = "/activity/${selectedChannel.id}/invite"
                        ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                    }
                )
            }

            options += ChannelOptionItemState(
                title = stringResource(id = R.string.custom_channel_action_manageParticipants_title),
                callback = {
                    val route = "/manage-activity/${selectedChannel.id}/participants"
                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                }
            )
        }
    }

    // START: mute/unmute actions

    if (selectedChannel.config.muteEnabled && selectedChannel.ownCapabilities.contains(ChannelCapabilities.MUTE_CHANNEL)) {
        options += if (isMuted) {
            ChannelOptionItemState(
                title = stringResource(id = R.string.custom_channel_action_unmute_title),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_unmute,
                action = UnmuteChannel(selectedChannel),
            )
        } else {
            ChannelOptionItemState(
                title = stringResource(id = R.string.custom_channel_action_mute_title),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_mute,
                action = MuteChannel(selectedChannel),
            )
        }
    }

    // START: leave channel action

    if (!selectedChannel.isDirectMessageChannel()) {
        val hasCapability = selectedChannel.ownCapabilities.contains(ChannelCapabilities.LEAVE_CHANNEL)

        val isAllowedToLeaveChannel =
            hasCapability &&
            (
                // participants and co-hosts always see the leave button
                myMember?.amiParticipantRole == AmiParticipantRole.Participant ||
                myMember?.amiParticipantRole == AmiParticipantRole.PseudoOrganizer ||
                // hosts will only see the button if the activity is deleted/expired
                (isMainHost && activityIsActive == 0)
            )

        if (isAllowedToLeaveChannel) {
            options += ChannelOptionItemState(
                // Copy is "leave activity and remove chat"
                // This is not always correct.
                // But we don't want the trouble of checking the current participant status here.
                // We don't think it's going to bother a lot of people, so we just cope with it
                title = stringResource(id = R.string.custom_channel_action_leave_title),
                textColor = TextColor.Danger,
                action = LeaveChannel(selectedChannel),
            )
        }
    }

    // START: hide channel action

    if (selectedChannel.isDirectMessageChannel() && otherUser?.isSupportTeamMember == false) {
        options += ChannelOptionItemState(
            title = stringResource(id = R.string.custom_channel_action_archive_title),
            textColor = TextColor.Danger,
            action = HideChannel(selectedChannel),
        )
    }

    return options
}