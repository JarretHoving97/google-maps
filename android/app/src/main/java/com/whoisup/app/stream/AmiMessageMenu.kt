package com.whoisup.app.stream

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiButtonLabel
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.TextColor
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.startThreadActivity
import io.getstream.chat.android.client.utils.message.isGiphy
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.SyncStatus
import io.getstream.chat.android.models.User
import io.getstream.chat.android.ui.common.feature.messages.composer.capabilities.canSendMessage
import io.getstream.chat.android.ui.common.state.messages.Copy
import io.getstream.chat.android.ui.common.state.messages.Delete
import io.getstream.chat.android.ui.common.state.messages.Edit
import io.getstream.chat.android.ui.common.state.messages.MarkAsUnread
import io.getstream.chat.android.ui.common.state.messages.MessageAction
import io.getstream.chat.android.ui.common.state.messages.MessageMode
import io.getstream.chat.android.ui.common.state.messages.Reply
import io.getstream.chat.android.ui.common.state.messages.Resend
import io.getstream.chat.android.ui.common.state.messages.ThreadReply
import io.getstream.chat.android.ui.common.state.messages.composer.MessageComposerState
import io.getstream.chat.android.ui.common.state.messages.list.SelectedMessageOptionsState
import io.getstream.chat.android.ui.common.state.messages.list.SelectedMessageState
import io.getstream.chat.android.ui.common.state.messages.updateMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.Duration
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.temporal.ChronoUnit

@Composable
fun AmiMessageMenu(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    selectedMessageState: SelectedMessageState?,
    currentUser: User?,
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    val selectedMessage = selectedMessageState?.message ?: Message()

    val ownCapabilities = selectedMessageState?.ownCapabilities ?: setOf()

    val messageComposerState by composerViewModel.messageComposerState.collectAsState()

    val newMessageOptions = messageOptions(
        messageComposerState = messageComposerState,
        selectedMessage = selectedMessage,
        currentUser = currentUser,
        isInThread = listViewModel.messageMode is MessageMode.MessageThread,
        ownCapabilities = ownCapabilities,
    )

    var messageOptions by remember {
        mutableStateOf<List<MessageOptionItemState>>(emptyList())
    }

    if (newMessageOptions.isNotEmpty()) {
        messageOptions = newMessageOptions
    }

    val visible = selectedMessageState is SelectedMessageOptionsState && selectedMessage.id.isNotEmpty()

    AmiSimpleMenu(
        visible = visible,
        onDismiss = remember(listViewModel) { { listViewModel.removeOverlay() } }
    ) {
        if (visible) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val canLeaveReaction =
                    ownCapabilities.contains(ChannelCapabilities.SEND_REACTION)

                if (canLeaveReaction) {
                    AmiReactionOptions(
                        listViewModel = listViewModel,
                        composerViewModel = composerViewModel,
                        selectedMessage = selectedMessage,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(CircleShape)
                            .background(CustomTheme.colorScheme.surface)
                            .horizontalScroll(rememberScrollState())
                            .padding(4.dp)
                    )
                }

                messageOptions.forEach { option ->
                    key(option.action) {
                        AmiButtonLabel(
                            title = option.title,
                            iconId = option.iconId,
                            textColor = option.textColor,
                            onClick = {
                                option.action.updateMessage(option.action.message).let {
                                    if (it is ThreadReply) {
                                        // We override this particular action behavior,
                                        // because the default behavior is just not acceptable.
                                        // The default behavior transforms the current view into a thread,
                                        // instead of starting a new activity/view, like what would be expected in our opinion.
                                        // Additionally, the starting a new thread approach. makes it easier to customize stuff.
                                        coroutineScope.launch(Dispatchers.Default) {
                                            startThreadActivity(context, listViewModel.channel.cid, it.message.id, it.message.parentId)
                                        }
                                    } else {
                                        composerViewModel.performMessageAction(it)
                                        listViewModel.performMessageAction(it)
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

internal class MessageOptionItemState(
    val title: String,
    @DrawableRes val iconId: Int = com.whoisup.app.R.drawable.angle_right,
    val textColor: TextColor? = null,
    val action: MessageAction,
)

@Composable
internal fun messageOptions(
    messageComposerState: MessageComposerState,
    selectedMessage: Message,
    currentUser: User?,
    isInThread: Boolean,
    ownCapabilities: Set<String>,
): List<MessageOptionItemState> {
    if (selectedMessage.id.isEmpty()) {
        return emptyList()
    }

    val selectedMessageUserId = selectedMessage.user.id

    val isTextOnlyMessage = selectedMessage.text.isNotEmpty() && selectedMessage.attachments.isEmpty()
    val hasLinks = selectedMessage.attachments.any {
        // @TODO: hasLink is private(?)
        // it.hasLink() && !it.isGiphy()
        false
    }
    val isOwnMessage = selectedMessageUserId == currentUser?.id
    val isMessageSynced = selectedMessage.syncStatus == SyncStatus.COMPLETED
    val isMessageFailed = selectedMessage.syncStatus == SyncStatus.FAILED_PERMANENTLY

    // user capabilities
    val canQuoteMessage = ownCapabilities.contains(ChannelCapabilities.QUOTE_MESSAGE)
    val canThreadReply = ownCapabilities.contains(ChannelCapabilities.SEND_REPLY)
    val canDeleteOwnMessage = ownCapabilities.contains(ChannelCapabilities.DELETE_OWN_MESSAGE)
    val canDeleteAnyMessage = ownCapabilities.contains(ChannelCapabilities.DELETE_ANY_MESSAGE)
    val canEditOwnMessage = ownCapabilities.contains(ChannelCapabilities.UPDATE_OWN_MESSAGE)
    val canMarkAsUnread = ownCapabilities.contains(ChannelCapabilities.READ_EVENTS)

    val isThreadReplyPossible = !isInThread && isMessageSynced && canThreadReply
    val isQuoteMessagePossible = messageComposerState.canSendMessage() && isMessageSynced && canQuoteMessage && !selectedMessage.user.isSupportTeamMember

    val isAllowedByCreatedAt = selectedMessage.createdAt?.let {
        val diffInMinutes = Duration.between(
            ZonedDateTime.ofInstant(
                it.toInstant(),
                ZoneId.systemDefault()
            ).truncatedTo(ChronoUnit.MINUTES),
            ZonedDateTime.now(ZoneId.systemDefault()).truncatedTo(ChronoUnit.MINUTES)
        ).toMinutes()

        diffInMinutes < 15
    } ?: true // if `createdAt == null`, message has likely not been synced yet

    val isDeleteMessagePossible = (isMessageFailed || isAllowedByCreatedAt) && isOwnMessage && canDeleteOwnMessage
    val isEditMessagePossible = isAllowedByCreatedAt && (isOwnMessage && canEditOwnMessage) && !selectedMessage.isGiphy()

    return listOfNotNull(
        if (isOwnMessage && isMessageFailed) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_resend_message),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_resend,
                action = Resend(selectedMessage),
            )
        } else {
            null
        },
        if (isQuoteMessagePossible) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_reply),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_reply,
                action = Reply(selectedMessage),
            )
        } else {
            null
        },
        if (isThreadReplyPossible) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_thread_reply),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_thread,
                action = ThreadReply(selectedMessage),
            )
        } else {
            null
        },
        if (!isOwnMessage && !isInThread && canMarkAsUnread) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_mark_as_unread),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_mark_as_unread,
                action = MarkAsUnread(selectedMessage),
            )
        } else {
            null
        },
        if (isTextOnlyMessage || hasLinks) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_copy_message),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_copy,
                action = Copy(selectedMessage),
            )
        } else {
            null
        },
        if (isEditMessagePossible) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_edit_message),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_edit,
                action = Edit(selectedMessage),
            )
        } else {
            null
        },
        if (isDeleteMessagePossible || canDeleteAnyMessage) {
            MessageOptionItemState(
                title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_delete_message),
                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_delete,
                textColor = TextColor.Danger,
                action = Delete(selectedMessage),
            )
        } else {
            null
        },
    )
}