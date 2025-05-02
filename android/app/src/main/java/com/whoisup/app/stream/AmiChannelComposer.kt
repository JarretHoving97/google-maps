package com.whoisup.app.stream

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.DisableTouch
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.state.messages.attachments.Images
import io.getstream.chat.android.compose.ui.components.composer.CoolDownIndicator
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.ui.common.state.messages.Edit

@Composable
fun AmiChannelComposer(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
) {
    val messageComposerState by composerViewModel.messageComposerState.collectAsState()

    val snackbarHostState = remember { SnackbarHostState() }

    MessageInputValidationError(
        validationErrors = messageComposerState.validationErrors,
        snackbarHostState = snackbarHostState,
    )

    Column {
        val isInEditMode = messageComposerState.action is Edit

        val canSendMessage = messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)
        val canSendAttachments = messageComposerState.ownCapabilities.contains(ChannelCapabilities.UPLOAD_FILE)

        val showAttachmentsButton = !isInEditMode && canSendMessage && canSendAttachments

        Box(
            modifier = Modifier
                .height(2.dp)
                .fillMaxWidth()
                .background(CustomTheme.colorScheme.surfaceHard)
        )

        DisableTouch(
            disableTouch = !canSendMessage,
            modifier = if (canSendMessage) {
                Modifier
            } else {
                Modifier.alpha(0.4f)
            }
        ) {
            Row(
                modifier = Modifier.padding(
                    start = if (showAttachmentsButton) {
                        0.dp
                    } else {
                        8.dp
                    },
                    top = 8.dp,
                    end = 8.dp,
                    bottom = 8.dp
                ),
                verticalAlignment = Alignment.CenterVertically
            ) {
                AnimatedVisibility(visible = showAttachmentsButton) {
                    AmiIconButton(
                        size = 40.dp,
                        color = Color.Transparent,
                        iconColor = CustomTheme.colorScheme.onBackground,
                        iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_add,
                        onClick = remember(attachmentsPickerViewModel) {
                            {
                                // Reset the pickerMode to `Images`
                                // This is a workaround, until https://github.com/GetStream/stream-chat-android/pull/5614 gets merged
                                attachmentsPickerViewModel.changeAttachmentPickerMode(Images) { false }

                                attachmentsPickerViewModel.changeAttachmentState(true)
                            }
                        },
                    )
                }

                AmiChannelComposerInput(
                    listViewModel = listViewModel,
                    composerViewModel = composerViewModel,
                    messageComposerState = messageComposerState,
                    onValueChange = { composerViewModel.setMessageInput(it) },
                    onAttachmentRemoved = { composerViewModel.removeSelectedAttachment(it) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                )

                if (messageComposerState.coolDownTime > 0 && !isInEditMode) {
                    CoolDownIndicator(coolDownTime = messageComposerState.coolDownTime)
                } else {
                    Spacer(modifier = Modifier.width(8.dp))

                    SendButton(
                        value = messageComposerState.inputValue,
                        validationErrors = messageComposerState.validationErrors,
                        attachments = messageComposerState.attachments,
                        ownCapabilities = messageComposerState.ownCapabilities,
                        onSendMessage = { input, attachments ->
                            val message = composerViewModel.buildNewMessage(input, attachments)
                            composerViewModel.sendMessage(message)
                        },
                    )
                }
            }
        }

        if (snackbarHostState.currentSnackbarData != null) {
            SnackbarPopup(
                snackbarHostState = snackbarHostState
            )
        }

        if (messageComposerState.mentionSuggestions.isNotEmpty()) {
            // @TODO: custom UI for MentionSuggestionList
//            MentionSuggestionList(
//                users = messageComposerState.mentionSuggestions,
//                onMentionSelected = { composerViewModel.selectMention(it) },
//            )
        }

        if (messageComposerState.commandSuggestions.isNotEmpty()) {
            // we do not use instant commands (for now),
        }
    }
}