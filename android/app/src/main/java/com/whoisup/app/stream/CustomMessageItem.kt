package com.whoisup.app.stream

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.AnimationConstants
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.Icon
import androidx.compose.material.ripple
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.helpers.getColorByHashingString
import com.whoisup.app.modifiers.layoutPadding
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isThreadStartOptimistic
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.DateTimeFormat
import com.whoisup.app.utils.getLocale
import com.whoisup.app.utils.intlDateTimeFormat
import com.whoisup.app.utils.startThreadActivity
import io.getstream.chat.android.client.utils.message.belongsToThread
import io.getstream.chat.android.client.utils.message.isDeleted
import io.getstream.chat.android.client.utils.message.isErrorOrFailed
import io.getstream.chat.android.compose.ui.messages.list.HighlightFadeOutDurationMillis
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.core.internal.InternalStreamChatApi
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.models.SyncStatus
import io.getstream.chat.android.ui.common.state.messages.list.MessageFocused
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState
import io.getstream.chat.android.ui.common.state.messages.list.MessagePosition
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.ZoneId
import java.time.ZonedDateTime

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AmiChannelMessageItem(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    onUserAvatarClick: (String) -> Unit,
    onWalkthroughClick: (slideKey: String?) -> Unit,
) {
    val position = messageItem.groupPosition
    val spacerSize =
        if (messageItem.isInThread && messageItem.isThreadStartOptimistic()) {
            0.dp
        } else if (position.contains(MessagePosition.NONE) || position.contains(MessagePosition.TOP)) {
            16.dp
        } else {
            1.dp
        }

    val message = messageItem.message
    val focusState = messageItem.focusState

    val interactionSource = remember { MutableInteractionSource() }

    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    val clickModifier = if (message.isDeleted()) {
        Modifier
    } else {
        Modifier.combinedClickable(
            interactionSource = interactionSource,
            indication = ripple(),
            onClick = {
                val layoutKey = messageItem.message.extraData["layoutKey"] as? String

                when (layoutKey) {
                    MessageLayoutKeyEnum.Onboarding.value -> {
                        onWalkthroughClick(null)
                    }
                    MessageLayoutKeyEnum.HowToHost.value -> {
                        onWalkthroughClick("host")
                    }
                    MessageLayoutKeyEnum.HowToJoin.value -> {
                        onWalkthroughClick("join")
                    }
                }

                val messageComposerState = composerViewModel.messageComposerState.value

                val isMessageSynced = messageItem.message.syncStatus == SyncStatus.COMPLETED
                val canThreadReply = messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_REPLY)
                val isThreadReplyPossible = !messageItem.isInThread && isMessageSynced && canThreadReply

                val canOpenThread = if (isThreadReplyPossible) {
                    true
                } else if (!messageItem.isInThread && messageItem.message.belongsToThread()) {
                    // Even if you cannot send messages in the thread,
                    // if there _is_ a thread, a user should still be able to read the messages inside the thread
                    true
                } else {
                    false
                }

                if (canOpenThread) {
                    coroutineScope.launch(Dispatchers.Default) {
                        startThreadActivity(context, listViewModel.channel.cid, message.id, message.parentId)
                    }
                }

//                Below is the (deducted) code of how stream handled this for reference.
//                This isn't really viable code, as it performs magic to transform the current channel view into a thread view.
//                But (to us) it makes more sense to just start an entire new activity with a dedicated thread view.
//                if (message.belongsToThread()) {
//                    composerViewModel.setMessageMode(MessageMode.MessageThread(message))
//                    listViewModel.openMessageThread(message)
//                } else {
//                    val action = ThreadReply(message)
//                    composerViewModel.performMessageAction(action)
//                    listViewModel.performMessageAction(action)
//                }
            },
            onLongClick = {
                // @TODO
                // if (!message.isUploading()) {
                listViewModel.selectMessage(message)
            },
        )
    }

    val backgroundColor = if (focusState is MessageFocused) {
        CustomTheme.colorScheme.highlight
    } else {
        // We can't use `Color.Transparent` here because the fade animation would glitch for some reason
        CustomTheme.colorScheme.background.copy(alpha = 0f)
    }

    val color = animateColorAsState(
            targetValue = backgroundColor,
            animationSpec = tween(
                durationMillis = if (focusState is MessageFocused) {
                    AnimationConstants.DefaultDurationMillis
                } else {
                    HighlightFadeOutDurationMillis
                },
            ),
        ).value

    val contentAlignment = if (messageItem.isMine) {
        Alignment.BottomEnd
    } else {
        Alignment.BottomStart
    }

    val horizontalAlignment = if (messageItem.isMine) {
        Alignment.End
    } else {
        Alignment.Start
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight()
            .padding(top = spacerSize)
            .background(color = color)
            .then(clickModifier)
            .padding(horizontal = 12.dp),
        contentAlignment = contentAlignment,
    ) {
        Row(
            modifier = Modifier.widthIn(max = 300.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            MessageItemAvatarContent(
                messageItem = messageItem,
                listViewModel = listViewModel,
                onUserAvatarClick = onUserAvatarClick
            )

            Column(horizontalAlignment = horizontalAlignment) {
                MessageItemHeaderContent(
                    messageItem = messageItem,
                    listViewModel = listViewModel,
                )

                // @TODO:
                // if (messageItem.message.isEmojiOnlyWithoutBubble()) {
                //     EmojiMessageContent(

                RegularMessageContent(
                    interactionSource = interactionSource,
                    messageItem = messageItem,
                    listViewModel = listViewModel,
                    composerViewModel = composerViewModel
                )

                MessageItemReactionsContent(
                    messageItem = messageItem,
                    listViewModel = listViewModel
                )

                DefaultMessageItemFooterContent(messageItem = messageItem)
            }
        }
    }
}

@Composable
internal fun RowScope.MessageItemAvatarContent(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    onUserAvatarClick: (String) -> Unit,
) {
    if (!listViewModel.channel.isDirectMessageChannel() && !messageItem.isMine) {
        if (
            messageItem.groupPosition.contains(MessagePosition.BOTTOM) ||
            messageItem.groupPosition.contains(MessagePosition.NONE)
        ) {
            AmiAvatar(
                user = UserForAmiAvatar(
                    id = messageItem.message.user.id,
                    name = messageItem.message.user.name,
                    avatarUrl = messageItem.message.user.image
                ),
                modifier = Modifier
                    .padding(bottom = 4.dp)
                    .align(Alignment.Bottom),
                size = 24.dp,
                onClick = {
                    onUserAvatarClick(messageItem.message.user.id)
                }
            )
        } else {
            Spacer(modifier = Modifier.size(24.dp))
        }
    }
}

@Composable
internal fun MessageItemHeaderContent(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
) {
    val message = messageItem.message

    if (!listViewModel.channel.isDirectMessageChannel() && !messageItem.isMine &&
        (
            messageItem.groupPosition.contains(MessagePosition.TOP) ||
            messageItem.groupPosition.contains(MessagePosition.NONE)
        )
    ) {
        BasicText(
            text = message.user.name,
            modifier = Modifier.padding(start = 8.dp), // Offset by just a bit, because it looks a bit strange otherwise
            style = CustomTheme.typography.captionSmall.copy(color = getColorByHashingString(message.user.name)),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }

    /* we're not using pinned messages */
    // if (message.pinned) {
}

@Composable
internal fun ColumnScope.DefaultMessageItemFooterContent(
    messageItem: MessageItemState,
) {
    val showThreadReplyCount = !messageItem.message.isDeleted() && messageItem.isThreadStartOptimistic()

    if (messageItem.showMessageFooter || showThreadReplyCount) {
        val date = messageItem.message.createdAt ?: messageItem.message.createdLocallyAt

        if (date != null) {
            val zonedDateTime = ZonedDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault())

            val timeText = intlDateTimeFormat(zonedDateTime, DateTimeFormat.Hour2Digit_Minute2Digit, getLocale())

            val paddingValues = if (messageItem.isMine) {
                PaddingValues(end = 8.dp)
            } else {
                PaddingValues(start = 8.dp)
            }

            val text = if (!messageItem.message.isDeleted() && messageItem.message.messageTextUpdatedAt != null) {
                "${stringResource(id = R.string.stream_compose_message_list_footnote_edited)} - $timeText"
            } else {
                timeText
            }

            Row(
                modifier = Modifier.padding(paddingValues),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                BasicText(
                    text = text,
                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft)
                )

                if (showThreadReplyCount) {
                    val threadFooterText = LocalContext.current.resources.getQuantityString(
                        io.getstream.chat.android.compose.R.plurals.stream_compose_message_list_thread_separator,
                        messageItem.message.replyCount,
                        messageItem.message.replyCount,
                    )
                    BasicText(
                        text = threadFooterText,
                        style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.primary)
                    )
                }
            }
        }
    }
    // @TODO
    // things to show:
    // - message translated
    // - sent/read icons
    // - sent/uploading status
}

@Composable
internal fun MessageItemReactionsContent(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
) {
    val message = messageItem.message

    if (!message.isDeleted()) {
        val options = message.reactionCounts
            .mapNotNull { reaction ->
                if (ChatTheme.reactionIconFactory.isReactionSupported(reaction.key)) {
                    return@mapNotNull reaction
                }

                return@mapNotNull null
            }
            .sortedByDescending { it.value }

        if (options.isNotEmpty()) {
            Row(
                modifier = Modifier
                    .layoutPadding(vertical = (-6).dp)
                    .padding(start = 4.dp, end = 4.dp, bottom = 6.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .border(
                        BorderStroke(2.dp, CustomTheme.colorScheme.background),
                        RoundedCornerShape(16.dp)
                    )
                    .clickable(onClick = {
                        listViewModel.selectReactions(message)
                    })
                    .background(CustomTheme.colorScheme.surfaceHard)
                    .padding(6.dp),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                options.forEach { option ->
                    // val isSelected = message.ownReactions.any { it.type == option.key }
                    val painter = ChatTheme.reactionIconFactory.createReactionIcon(option.key).getPainter(false)

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(2.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Image(
                            modifier = Modifier
                                .size(16.dp)
                                .align(Alignment.CenterVertically),
                            painter = painter,
                            contentDescription = null,
                        )

                        // if (options.size == 1 && option.value > 1 || options.size > 1 && option.value > 0) {
                        if (option.value > 1) {
                            BasicText(
                                text = "${option.value}",
                                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft)
                            )
                        }
                    }
                }
            }
        }
    }
}

@OptIn(InternalStreamChatApi::class)
@Composable
internal fun RegularMessageContent(
    interactionSource: MutableInteractionSource,
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    // @TODO: implement GIFies

    val message = messageItem.message
    val position = messageItem.groupPosition
    val ownsMessage = messageItem.isMine

    val messageBubbleShape = if (position.contains(MessagePosition.NONE)) {
        RoundedCornerShape(16.dp)
    } else if (position.contains(MessagePosition.TOP)) {
        if (position.contains(MessagePosition.BOTTOM)) {
            RoundedCornerShape(16.dp)
        } else if (ownsMessage) {
            RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp, bottomStart = 16.dp, bottomEnd = 3.dp)
        } else {
            RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp, bottomStart = 3.dp, bottomEnd = 16.dp)
        }
    } else if (position.contains(MessagePosition.BOTTOM)) {
        if (ownsMessage) {
            RoundedCornerShape(topStart = 16.dp, topEnd = 3.dp, bottomStart = 16.dp, bottomEnd = 16.dp)
        } else {
            RoundedCornerShape(topStart = 3.dp, topEnd = 16.dp, bottomStart = 16.dp, bottomEnd = 16.dp)
        }
    } else if (position.contains(MessagePosition.MIDDLE)) {
        if (ownsMessage) {
            RoundedCornerShape(topStart = 16.dp, topEnd = 3.dp, bottomStart = 16.dp, bottomEnd = 3.dp)
        } else {
            RoundedCornerShape(topStart = 3.dp, topEnd = 16.dp, bottomStart = 3.dp, bottomEnd = 16.dp)
        }
    } else {
        RoundedCornerShape(16.dp)
    }

    val messageBubbleColor = when {
        message.isDeleted() -> when (ownsMessage) {
            true -> CustomTheme.colorScheme.primary.copy(alpha = 0.75f)
            else -> CustomTheme.colorScheme.surfaceHard.copy(alpha = 0.75f)
        }
        else -> when (ownsMessage) {
            true -> CustomTheme.colorScheme.primary
            else -> CustomTheme.colorScheme.surfaceHard
        }
    }

    Box {
        Box(
            modifier = Modifier
                // The next modifier can make the app crash if a really long text is provided to the `RegularMessageContent`
                // .width(IntrinsicSize.Max)
                .clip(messageBubbleShape)
                .background(messageBubbleColor),
        ) {
            when {
                message.isDeleted() -> DeletedMessageContent(
                    messageItem = messageItem
                )
                else -> CustomDefaultMessageContent(
                    interactionSource = interactionSource,
                    messageItem = messageItem,
                    listViewModel = listViewModel,
                    composerViewModel = composerViewModel
                )
            }
        }

        if (message.isErrorOrFailed()) {
            Icon(
                modifier = Modifier
                    .layoutPadding(horizontal = (-4).dp, vertical = (-4).dp)
                    .size(24.dp)
                    .align(Alignment.BottomEnd),
                painter = painterResource(id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_error),
                contentDescription = null,
                tint = ChatTheme.colors.errorAccent,
            )
        }
    }
}

@Composable
internal fun DeletedMessageContent(messageItem: MessageItemState) {
    val textColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary.copy(alpha = 0.75f)
    } else {
        CustomTheme.colorScheme.onSurface.copy(alpha = 0.75f)
    }

    BasicText(
        text = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_message_deleted),
        modifier = Modifier
            .padding(
                horizontal = 12.dp,
                vertical = 8.dp,
            ),
        style = CustomTheme.typography.subhead.copy(color = textColor, fontStyle = FontStyle.Italic),
    )
}