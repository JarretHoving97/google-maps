package com.whoisup.app.stream

import androidx.activity.compose.ManagedActivityResultLauncher
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.utils.attachment.isImage
import io.getstream.chat.android.client.utils.attachment.isVideo
import io.getstream.chat.android.compose.state.mediagallerypreview.MediaGalleryPreviewResult
import io.getstream.chat.android.compose.ui.attachments.content.MediaAttachmentContent
import io.getstream.chat.android.compose.ui.attachments.content.MediaAttachmentPreviewContent
import io.getstream.chat.android.compose.ui.attachments.content.MediaAttachmentQuotedContent
import io.getstream.chat.android.models.AttachmentType

class CustomMediaAttachmentFactory(
    mediaGalleryPreviewLauncher: (ManagedActivityResultLauncher<MediaGalleryPreviewContract.Input, MediaGalleryPreviewResult?>)?,
) : AmiAttachmentFactory(
    canHandle = {
        it.isImage() || it.isVideo()
    },
    previewText = @Composable { attachment ->
        if (attachment.isImage()) {
            AttachmentContent(
                iconId = R.drawable.attachment_photo,
                description = stringResource(id = R.string.custom_attachment_tag_photo)
            )
        } else if (attachment.isVideo()) {
            AttachmentContent(
                iconId = R.drawable.attachment_video,
                description = stringResource(id = R.string.custom_attachment_tag_video)
            )
        } else {
            AttachmentContent(
                iconId = R.drawable.attachment_file,
                description = stringResource(id = R.string.custom_attachment_tag_file)
            )
        }
    },
    previewContent = { attachment, onAttachmentRemoved ->
        // `MediaAttachmentPreviewItem` is marked private, so we have to use `MediaAttachmentPreviewContent` instead
        // We have to surround it with a `Box` (with an explicit size( though,
        // because otherwise a LazyRow would be rendered inside a LazyRow,
        // which would crash.
        Box(
            modifier = Modifier
                .size(MediaAttachmentPreviewItemSize.dp)
        ) {
            MediaAttachmentPreviewContent(
                attachments = listOf(attachment),
                onAttachmentRemoved = onAttachmentRemoved,
            )
        }
    },
    content = @Composable { modifier, state ->
        MediaAttachmentContent(
            state = state,
            modifier = modifier,
            onItemClick = {
                mediaGalleryPreviewLauncher?.launch(
                    MediaGalleryPreviewContract.Input(
                        message = it.message,
                        initialPosition = it.attachmentPosition,
                    ),
                )
            },
            itemOverlayContent = { attachmentType ->
                if (attachmentType == AttachmentType.VIDEO) {
                    PlayButton()
                }
            }
        )
    },
    quotedContent = @Composable { modifier, attachment ->
        MediaAttachmentQuotedContent(modifier = modifier, attachment = attachment)
    },
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

/**
 * The default size of the [MediaAttachmentPreviewItem]
 * composable.
 */
internal const val MediaAttachmentPreviewItemSize: Int = 95
