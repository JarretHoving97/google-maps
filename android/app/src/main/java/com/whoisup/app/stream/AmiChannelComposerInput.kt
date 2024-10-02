package com.whoisup.app.stream

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.AmiTextField
import com.whoisup.app.components.DcIcon
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.ui.common.state.messages.Edit
import io.getstream.chat.android.ui.common.state.messages.Reply
import io.getstream.chat.android.ui.common.state.messages.composer.MessageComposerState

@Composable
fun AmiChannelComposerInput(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    messageComposerState: MessageComposerState,
    onValueChange: (String) -> Unit,
    onAttachmentRemoved: (Attachment) -> Unit,
    modifier: Modifier = Modifier,
) {
    fun dismissActions() {
        listViewModel.dismissAllMessageActions()
        composerViewModel.dismissMessageActions()
    }

    val (value, attachments, activeAction) = messageComposerState
    val canSendMessage = messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)

    val placeholder =
        if (messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)) {
            stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_message_label)
        } else {
            stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_cannot_send_messages_label)
        }

    AmiTextField(
        value = value,
        onValueChange = onValueChange,
        // enabled = canSendMessage, // @TODO(1)
        placeholder = placeholder,
        modifier = modifier,
        maxLines = 5,
        headingContent = {
            val paddingValues = PaddingValues(start = 8.dp, top = 8.dp, end = 8.dp)

            AnimatedVisibility(visible = activeAction is Edit) {
                Row(
                    modifier = Modifier.padding(paddingValues),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    DcIcon(
                        id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_edit,
                        contentDescription = null,
                        size = 12.dp,
                        color = CustomTheme.colorScheme.onSurfaceSoft,
                    )

                    BasicText(
                        text = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_edit_message),
                        modifier = Modifier.weight(1f),
                        style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft)
                    )

                    AmiIconButton(
                        size = 20.dp,
                        color = CustomTheme.colorScheme.danger,
                        iconColor = CustomTheme.colorScheme.onDanger,
                        iconId = com.whoisup.app.R.drawable.close,
                        onClick = remember(
                            listViewModel,
                            composerViewModel
                        ) {
                            { dismissActions() }
                        }
                    )
                }
            }

            AnimatedValueVisibility(value = activeAction?.takeIf { it is Reply}) {
                Box(modifier = Modifier.padding(paddingValues)) {
                    CustomQuotedMessageContent(
                        message = it.message,
                        replyMessage = null,
                        currentUser = messageComposerState.currentUser,
                        modifier = Modifier.fillMaxWidth()
                    )

                    Box(modifier = Modifier
                        .padding(top = 4.dp, end = 4.dp)
                        .align(Alignment.TopEnd)) {
                        AmiIconButton(
                            size = 20.dp,
                            color = CustomTheme.colorScheme.surface,
                            iconColor = CustomTheme.colorScheme.onSurfaceSoft,
                            iconId = com.whoisup.app.R.drawable.close,
                            onClick = remember(
                                listViewModel,
                                composerViewModel
                            ) {
                                { dismissActions() }
                            }
                        )
                    }
                }
            }

            AnimatedVisibility(visible = attachments.isNotEmpty() && activeAction !is Edit) {
                Box(modifier = Modifier.padding(paddingValues)) {
                    val previewFactory =
                        ChatTheme.attachmentFactories.firstOrNull { it.canHandle(attachments) }

                    previewFactory?.previewContent?.invoke(
                        Modifier
                            .fillMaxWidth()
                            .wrapContentHeight(),
                        attachments,
                        onAttachmentRemoved,
                    )
                }
            }
        }
    )
}