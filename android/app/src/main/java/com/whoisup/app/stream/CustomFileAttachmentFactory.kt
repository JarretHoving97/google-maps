package com.whoisup.app.stream

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import io.getstream.chat.android.client.utils.attachment.isAudio
import io.getstream.chat.android.client.utils.attachment.isFile
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentState
import io.getstream.chat.android.compose.ui.attachments.content.FileAttachmentImage
import io.getstream.chat.android.compose.ui.attachments.content.FileAttachmentItem
import io.getstream.chat.android.compose.ui.components.CancelIcon
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.ui.common.utils.MediaStringUtil

fun Attachment.isAnyFileType(): Boolean {
    return isFile() || isAudio()
}

class CustomFileAttachmentFactory : AmiAttachmentFactory(
    canHandle = {
        it.isAnyFileType()
    },
    previewText = @Composable { _ ->
        AttachmentContent(
            iconId = R.drawable.attachment_file,
            description = stringResource(id = R.string.custom_attachment_tag_file)
        )
    },
    previewContent = @Composable { attachment, onAttachmentRemoved ->
        FileAttachmentPreviewItem(
            attachment = attachment,
            onAttachmentRemoved = onAttachmentRemoved,
        )
    },
    content = @Composable { modifier, state ->
        FileAttachmentContent(
            modifier = modifier
                .wrapContentHeight()
                .width(ChatTheme.dimens.attachmentsContentFileWidth),
            attachmentState = state,
        )
    },
    quotedContent = null
)

@Composable
fun FileAttachmentPreviewItem(
    attachment: Attachment,
    onAttachmentRemoved: (Attachment) -> Unit
) {
    Surface(
        modifier = Modifier.padding(1.dp),
        color = ChatTheme.colors.appBackground,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, ChatTheme.colors.borders),
    ) {
        Row(
            modifier = Modifier
                .width(200.dp)
                .height(50.dp)
                .padding(vertical = 8.dp, horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            FileAttachmentImage(attachment = attachment, isMine = false)

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 8.dp),
                horizontalAlignment = Alignment.Start,
                verticalArrangement = Arrangement.Center,
            ) {
                Text(
                    text = attachment.title ?: attachment.name ?: "",
                    style = ChatTheme.typography.bodyBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = ChatTheme.colors.textHighEmphasis,
                )

                val fileSize = attachment.upload?.length()?.let { length ->
                    MediaStringUtil.convertFileSizeByteCount(length)
                }
                if (fileSize != null) {
                    Text(
                        text = fileSize,
                        style = ChatTheme.typography.footnote,
                        color = ChatTheme.colors.textLowEmphasis,
                    )
                }
            }

            CancelIcon(
                modifier = Modifier.padding(4.dp),
                onClick = { onAttachmentRemoved(attachment) },
            )
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun FileAttachmentContent(
    attachmentState: AttachmentState,
    modifier: Modifier = Modifier,
) {
    val previewHandlers = ChatTheme.attachmentPreviewHandlers

    val attachments = attachmentState.message.attachments.filter {
        it.isAnyFileType()
    }

    if (attachments.isNotEmpty()) {
        Column(
            modifier = modifier.combinedClickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
                onClick = {},
                onLongClick = { attachmentState.onLongItemClick(attachmentState.message) },
            ),
        ) {
            for (attachment in attachments) {
                FileAttachmentItem(
                    modifier = Modifier
                        .padding(2.dp)
                        .fillMaxWidth()
                        .combinedClickable(
                            indication = null,
                            interactionSource = remember { MutableInteractionSource() },
                            onClick = {
                                previewHandlers.firstOrNull { it.canHandle(attachment) }?.handleAttachmentPreview(attachment)
                            },
                            onLongClick = { attachmentState.onLongItemClick(attachmentState.message) },
                        ),
                    attachment = attachment,
                    showFileSize = { true },
                    isMine = attachmentState.isMine
                )
            }
        }
    }
}