package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentState
import io.getstream.chat.android.models.Attachment

open class AmiAttachmentFactory(
    val canHandle: (attachment: Attachment) -> Boolean,
    val previewText: @Composable (attachment: Attachment) -> AttachmentContent,
    val previewContent: (@Composable (
        attachment: Attachment,
        onAttachmentRemoved: (Attachment) -> Unit,
    ) -> Unit)?,
    val content: @Composable (
        modifier: Modifier,
        attachmentState: AttachmentState,
    ) -> Unit,
    val quotedContent: (@Composable (
        modifier: Modifier,
        attachment: Attachment,
    ) -> Unit)?,
)