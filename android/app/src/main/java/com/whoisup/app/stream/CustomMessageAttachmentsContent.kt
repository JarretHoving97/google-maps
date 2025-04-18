package com.whoisup.app.stream

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.state.mediagallerypreview.MediaGalleryPreviewResultType
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentState
import io.getstream.chat.android.compose.ui.attachments.content.UnsupportedAttachmentContent
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.ui.common.state.messages.Reply

@Composable
fun CustomMessageAttachmentsContent(
    message: Message,
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    val attachmentFactories = CustomTheme.attachmentFactories.filter { attachmentFactory ->
        message.attachments.any { attachment -> attachmentFactory.canHandle(attachment) }
    }

    if (attachmentFactories.isNotEmpty()) {
        val attachmentState = AttachmentState(
            message = message,
            onLongItemClick = { listViewModel.selectMessage(it) },
            onMediaGalleryPreviewResult = remember(composerViewModel, listViewModel) {
                {
                    when (it?.resultType) {
                        MediaGalleryPreviewResultType.QUOTE -> {
                            val message2 = listViewModel.getMessageById(it.messageId)

                            if (message2 != null) {
                                composerViewModel.performMessageAction(Reply(message))
                            }
                        }

                        MediaGalleryPreviewResultType.SHOW_IN_CHAT -> {
                            listViewModel.scrollToMessage(
                                messageId = it.messageId,
                                parentMessageId = it.parentMessageId,
                            )
                        }

                        null -> Unit
                    }
                }
            },
        )

        for (attachmentFactory in attachmentFactories) {
            attachmentFactory.content(Modifier.padding(2.dp), attachmentState)
        }
    } else if (message.attachments.isNotEmpty()) {
        UnsupportedAttachmentContent(
            modifier = Modifier
                .wrapContentHeight()
                .width(ChatTheme.dimens.attachmentsContentUnsupportedWidth),
        )
    }
}