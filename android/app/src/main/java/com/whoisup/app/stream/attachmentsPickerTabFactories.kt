package com.whoisup.app.stream

import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentsPickerImagesTabFactory
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentsPickerMediaCaptureTabFactory
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentsPickerTabFactory

fun attachmentsPickerTabFactories(): List<AttachmentsPickerTabFactory> = listOf(
    AttachmentsPickerImagesTabFactory(),
    AttachmentsPickerMediaCaptureTabFactory(
        AttachmentsPickerMediaCaptureTabFactory.PickerMediaMode.PHOTO_AND_VIDEO,
    ),
)