package com.whoisup.app.stream

import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContract
import com.whoisup.app.MediaGalleryPreviewActivity
import io.getstream.chat.android.compose.state.mediagallerypreview.MediaGalleryPreviewResult
import io.getstream.chat.android.models.Message

// This file is almost entirely copied from stream.
// But we cannot override the activity to start.
// So we copied the file, removed the params we do not need,
// and changed the `MediaGalleryPreviewActivity` to ours

/**
 * The contract used to start the [MediaGalleryPreviewActivity]
 * given a message ID and the position of the clicked attachment.
 */
class MediaGalleryPreviewContract :
    ActivityResultContract<MediaGalleryPreviewContract.Input, MediaGalleryPreviewResult?>() {

    /**
     * Creates the intent to start the [MediaGalleryPreviewActivity].
     * It receives a data pair of a [String] and an [Int] that represent the messageId and the attachmentPosition.
     *
     * @return The [Intent] to start the [MediaGalleryPreviewActivity].
     */
    override fun createIntent(context: Context, input: Input): Intent {
        return MediaGalleryPreviewActivity.getIntent(
            context,
            message = input.message,
            attachmentPosition = input.initialPosition,
        )
    }

    /**
     * We parse the result as [MediaGalleryPreviewResult], which can be null in case there is no result to return.
     *
     * @return The [MediaGalleryPreviewResult] or null if it doesn't exist.
     */
    override fun parseResult(resultCode: Int, intent: Intent?): MediaGalleryPreviewResult? {
        return intent?.getParcelableExtra(MediaGalleryPreviewActivity.KeyMediaGalleryPreviewResult)
    }

    /**
     * Defines the input for the [MediaGalleryPreviewContract].
     *
     * @param message The message containing the attachments.
     * @param initialPosition The initial position of the media gallery, based on the clicked item.
     */
    class Input(
        val message: Message,
        val initialPosition: Int = 0,
    )
}