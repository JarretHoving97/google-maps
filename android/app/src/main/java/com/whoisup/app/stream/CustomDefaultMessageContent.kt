package com.whoisup.app.stream

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiClickableText
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
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
                modifier =  Modifier
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
    }
}