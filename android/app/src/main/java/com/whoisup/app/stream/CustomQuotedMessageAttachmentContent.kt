package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import io.getstream.chat.android.models.Message

@Composable
fun CustomQuotedMessageAttachmentContent(message: Message) {
    val attachmentWithFactory = findFirstAttachmentWithFactory(message)

    attachmentWithFactory?.let {
        it.factory.quotedContent?.invoke(
            Modifier,
            it.attachment,
        )
    }
}