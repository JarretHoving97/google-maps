package com.whoisup.app.stream

import androidx.activity.compose.ManagedActivityResultLauncher
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.state.mediagallerypreview.MediaGalleryPreviewResult
import io.getstream.chat.android.compose.ui.attachments.AttachmentFactory
import io.getstream.chat.android.compose.ui.attachments.factory.AudioRecordAttachmentFactory
import io.getstream.chat.android.compose.ui.attachments.factory.FileAttachmentFactory
import io.getstream.chat.android.compose.ui.attachments.factory.MediaAttachmentFactory
import io.getstream.chat.android.compose.ui.attachments.factory.UnsupportedAttachmentFactory
import io.getstream.chat.android.compose.ui.attachments.factory.UploadAttachmentFactory
import io.getstream.chat.android.models.AttachmentType

fun attachmentFactories(
    mediaGalleryPreviewLauncher: (ManagedActivityResultLauncher<MediaGalleryPreviewContract.Input, MediaGalleryPreviewResult?>)?,
): List<AttachmentFactory> = listOf(
    UploadAttachmentFactory(),
    MediaAttachmentFactory(
        skipEnrichUrl = false,
        onContentItemClick = {
                _,
                message,
                attachmentPosition,
                _,
                _,
                _,
            ->
            mediaGalleryPreviewLauncher?.launch(
                MediaGalleryPreviewContract.Input(
                    message = message,
                    initialPosition = attachmentPosition,
                ),
            )
        },
        itemOverlayContent = { attachmentType ->
            if (attachmentType == AttachmentType.VIDEO) {
                PlayButton()
            }
        },
        previewItemOverlayContent = { attachmentType ->
            if (attachmentType == AttachmentType.VIDEO) {
                PlayButton()
            }
        },
    ),
    FileAttachmentFactory(),
    AudioRecordAttachmentFactory(),
    UnsupportedAttachmentFactory(),
)

@Composable
fun PlayButton() {
    Column(
        modifier = Modifier
            .background(color = CustomTheme.colorScheme.overlay, shape = CircleShape)
            .fillMaxWidth(0.25f),
        verticalArrangement = Arrangement.Center,
    ) {
        Image(
            modifier = Modifier
                .alignBy { measured ->
                    // emulated offset as seen in the design specs,
                    // otherwise the button is visibly off to the start of the screen
                    -(measured.measuredWidth * 1 / 8)
                }
                .aspectRatio(1f),
            painter = painterResource(id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_play),
            contentDescription = null,
            colorFilter = ColorFilter.tint(Color.White)
        )
    }
}