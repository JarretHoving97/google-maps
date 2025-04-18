package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.models.Message

data class AttachmentWithFactory(
    val attachment: Attachment,
    val factory: AmiAttachmentFactory,
)

@Composable
fun findFirstAttachmentWithFactory(message: Message): AttachmentWithFactory? {
    message.attachments.forEach { attachment ->
        CustomTheme.attachmentFactories.forEach { factory ->
            if (factory.canHandle(attachment)) {
                return AttachmentWithFactory(
                    attachment = attachment,
                    factory = factory
                )
            }
        }
    }

    return null
}