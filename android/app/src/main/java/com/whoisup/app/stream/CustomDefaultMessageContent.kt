package com.whoisup.app.stream

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.whoisup.app.R
import com.whoisup.app.components.AmiButtonTheme
import com.whoisup.app.components.AmiClickableText
import com.whoisup.app.components.DcIcon
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.utils.message.isDeleted
import io.getstream.chat.android.client.utils.message.isPoll
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState

@OptIn(ExperimentalFoundationApi::class)
@Composable
internal fun CustomDefaultMessageContent(
    interactionSource: MutableInteractionSource,
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    Column {
        if (messageItem.message.showInChannel) {
            ThreadMessageContentShownInChannel(messageItem)
        }

        val quotedMessage = messageItem.message.replyTo

        if (quotedMessage != null) {
            Box(
                modifier = Modifier
                    .padding(horizontal = 4.dp, vertical = 4.dp)
                    .combinedClickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onLongClick = { listViewModel.selectMessage(messageItem.message) },
                        onClick = {
                            listViewModel.scrollToMessage(
                                messageId = quotedMessage.id,
                                parentMessageId = quotedMessage.parentId,
                            )
                        },
                    ),
            ) {
                CustomQuotedMessageContent(
                    message = quotedMessage,
                    replyMessage = messageItem.message,
                    currentUser = messageItem.currentUser,
                )
            }
        }

        CustomMessageAttachmentsContent(
            message = messageItem.message,
            listViewModel = listViewModel,
            composerViewModel = composerViewModel
        )

        val layoutKey = messageItem.message.extraData["layoutKey"] as? String

        when (layoutKey) {
            MessageLayoutKeyEnum.Onboarding.value -> {
                AmiMessageWalkthrough(R.drawable.walkthrough_01)
            }
            MessageLayoutKeyEnum.HowToHost.value -> {
                AmiMessageWalkthrough(R.drawable.walkthrough_03)
            }
            MessageLayoutKeyEnum.HowToJoin.value -> {
                AmiMessageWalkthrough(R.drawable.walkthrough_04)
            }
        }

        if (messageItem.message.isPoll()) {
            // Since `listViewModel.pollState.selectedPoll` is not reactive,
            // we need to re-assign it if we notice changes on `messageItem.message.poll`
            // The next couple of lines are a workaround for that.
            // See: https://amigostech.slack.com/archives/C06U2JU0T9D/p1758800726294289
            val poll = messageItem.message.poll
            LaunchedEffect(poll) {
                if (poll != null) {
                    val selectedPoll = listViewModel.pollState.selectedPoll
                    if (selectedPoll != null && selectedPoll.poll.id == poll.id) {
                        listViewModel.updatePollState(poll, messageItem.message, selectedPoll.pollSelectionType)
                    }
                }
            }
        }

        if (messageItem.message.isPoll() && !messageItem.message.isDeleted()) {
            messageItem.message.poll?.let { poll ->
                PollMessageContent(
                    messageItem,
                    listViewModel,
                    poll
                )
            }
        }

        if (messageItem.message.text.isNotEmpty()) {
            val textColor = if (messageItem.isMine) {
                CustomTheme.colorScheme.onPrimary
            } else {
                CustomTheme.colorScheme.onSurface
            }

            val textStyle = CustomTheme.typography.subhead.copy(color = textColor)

            AmiClickableText(
                text = messageItem.message.text,
                textStyle = textStyle,
                modifier = Modifier
                    .padding(
                        horizontal = 12.dp,
                        vertical = 8.dp,
                    )
                    .clipToBounds(),
                allowMarkdown = messageItem.message.user.isSupportTeamMember,
                interactionSource = interactionSource,
                onLongPress = { listViewModel.selectMessage(messageItem.message) },
            )
        }

        AmiMessageActionButton(
            message = messageItem.message,
            modifier = Modifier
                .padding(
                    start = 12.dp,
                    bottom = 12.dp,
                    end = 12.dp
                ),
            theme = if (messageItem.isMine) {
                AmiButtonTheme(
                    color = CustomTheme.colorScheme.background,
                    textColor = CustomTheme.colorScheme.onBackground,
                )
            } else {
                AmiButtonTheme(
                    color = CustomTheme.colorScheme.primary,
                    textColor = CustomTheme.colorScheme.onPrimary,
                )
            }
        )
    }
}

@Composable
fun ThreadMessageContentShownInChannel(messageItem: MessageItemState) {
    val textColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary.copy(alpha = 0.75f)
    } else {
        CustomTheme.colorScheme.onSurfaceSoft
    }

    val alsoSendToChannelTextRes = if (messageItem.isInThread) {
        io.getstream.chat.android.compose.R.string.stream_compose_also_sent_to_channel
    } else {
        io.getstream.chat.android.compose.R.string.stream_compose_replied_to_thread
    }

    Row(
        modifier = Modifier.padding(
            start = 12.dp,
            top = 4.dp,
            end = 12.dp,
        ),
        horizontalArrangement = Arrangement.spacedBy(2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        DcIcon(
            id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_thread,
            contentDescription = null,
            size = 8.dp,
            color = textColor
        )

        BasicText(
            text = stringResource(alsoSendToChannelTextRes),
            style = CustomTheme.typography.captionSmall.copy(color = textColor, fontSize = 8.sp)
        )
    }
}