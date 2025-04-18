package com.whoisup.app.stream

import androidx.activity.compose.ManagedActivityResultLauncher
import io.getstream.chat.android.compose.state.mediagallerypreview.MediaGalleryPreviewResult
import io.getstream.chat.android.core.internal.InternalStreamChatApi

@OptIn(InternalStreamChatApi::class)
fun attachmentFactories(
    mediaGalleryPreviewLauncher: (ManagedActivityResultLauncher<MediaGalleryPreviewContract.Input, MediaGalleryPreviewResult?>)?,
): List<AmiAttachmentFactory> = listOf(
    CustomAudioRecordAttachmentFactory(),
    CustomMediaAttachmentFactory(mediaGalleryPreviewLauncher = mediaGalleryPreviewLauncher),
    CustomFileAttachmentFactory(),
)