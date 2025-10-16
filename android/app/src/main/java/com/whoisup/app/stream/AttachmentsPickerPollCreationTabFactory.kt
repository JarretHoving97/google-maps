package com.whoisup.app.stream

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.compose.material.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import io.getstream.chat.android.compose.R
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentPickerItemState
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentsPickerMode
import io.getstream.chat.android.compose.state.messages.attachments.Poll
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentPickerAction
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentPickerBack
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentPickerPollCreation
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentsPickerTabFactory
import io.getstream.chat.android.compose.ui.messages.attachments.poll.PollOptionItem
import io.getstream.chat.android.compose.ui.messages.attachments.poll.PollSwitchItem
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.core.ExperimentalStreamChatApi
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.ui.common.state.messages.composer.AttachmentMetaData

class AttachmentsPickerPollCreationTabFactory : AttachmentsPickerTabFactory {

    override val attachmentsPickerMode: AttachmentsPickerMode
        get() = Poll

    override fun isPickerTabEnabled(channel: Channel): Boolean =
        channel.ownCapabilities.contains(ChannelCapabilities.SEND_POLL)

    @Composable
    override fun PickerTabIcon(isEnabled: Boolean, isSelected: Boolean) {
        Icon(
            painter = painterResource(id = R.drawable.stream_compose_ic_poll),
            contentDescription = stringResource(id = R.string.stream_compose_poll_option),
            tint = when {
                isSelected -> ChatTheme.colors.primaryAccent
                isEnabled -> ChatTheme.colors.textLowEmphasis
                else -> ChatTheme.colors.disabled
            },
        )
    }

    @OptIn(ExperimentalStreamChatApi::class)
    @Composable
    override fun PickerTabContent(
        onAttachmentPickerAction: (AttachmentPickerAction) -> Unit,
        attachments: List<AttachmentPickerItemState>,
        onAttachmentsChanged: (List<AttachmentPickerItemState>) -> Unit,
        onAttachmentItemSelected: (AttachmentPickerItemState) -> Unit,
        onAttachmentsSubmitted: (List<AttachmentMetaData>) -> Unit,
    ) {
        val launcher = rememberLauncherForActivityResult(
            contract = PollCreationContract(),
            onResult = {
                if (it != null) {
                    // This is very ugly, but we cannot define a custom AttachmentPickerAction (yet)
                    // See: https://amigostech.slack.com/archives/C06U2JU0T9D/p1758697486275439
                    onAttachmentPickerAction(
                        AttachmentPickerPollCreation(
                            question = it.question,
                            options = it.options.map { option ->
                                PollOptionItem(title = option)
                            },
                            switches = listOf(
                                PollSwitchItem(
                                    title = "",
                                    enabled = it.multipleVotesAllowed,
                                    key = "multipleVotesAllowed",
                                )
                            )
                        )
                    )
                } else {
                    onAttachmentPickerAction.invoke(AttachmentPickerBack)
                }
            },
        )

        LaunchedEffect(Unit) {
            launcher.launch(Unit)
        }
    }
}