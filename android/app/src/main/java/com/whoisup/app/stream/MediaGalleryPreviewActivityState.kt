package com.whoisup.app.stream

import android.os.Parcelable
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.User
import kotlinx.parcelize.Parcelize

// This file is entirely copied from stream.
// But that one is marked internal unfortunately.

/**
 * Class used to parcelize the minimum necessary information
 * for proper function of the Media Gallery Preview screen.
 *
 * Using it avoids having to parcelize client models and parcelizing
 * overly large models.
 *
 * @param messageId The ID of the message containing the attachments.
 * @param userId The ID of the user who sent the message.
 * @param userName The name of the user who sent the message.
 * @param userImage The image of the user who sent the message.
 * @param userIsOnline The online status of the user who sent the message.
 * Set to false because we don't track the status inside the preview screen.
 * @param attachments The list of attachments contained in the original message.
 */
@Parcelize
internal data class MediaGalleryPreviewActivityState(
    val messageId: String,
    val userId: String,
    val userName: String,
    val userImage: String,
    val userIsOnline: Boolean = false,
    val attachments: List<MediaGalleryPreviewActivityAttachmentState>,
) : Parcelable

/**
 * Maps [Message] to [toMediaGalleryPreviewActivityState].
 */
internal fun Message.toMediaGalleryPreviewActivityState(): MediaGalleryPreviewActivityState =
    MediaGalleryPreviewActivityState(
        messageId = this.id,
        userId = this.user.id,
        userName = this.user.name,
        userImage = this.user.image,
        attachments = this.attachments.map { it.toMediaGalleryPreviewActivityAttachmentState() },
    )

/**
 * Maps [toMediaGalleryPreviewActivityState] to [Message].
 */
internal fun MediaGalleryPreviewActivityState.toMessage(): Message =
    Message(
        id = this.messageId,
        user = User(
            id = this.userId,
            name = this.userName,
            image = this.userImage,
        ),
        attachments = this.attachments.map { it.toAttachment() }.toMutableList(),
    )