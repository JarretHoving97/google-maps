package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.helpers.getColorByHashingString
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.User

/**
 * Represents the default quoted message content that shows an attachment preview, if available, and the message text.
 *
 * @param message The quoted message to show.
 * @param currentUser The currently logged in user.
 * @param modifier Modifier for styling.
 * @param replyMessage The message that contains the reply.
 */
@Composable
fun CustomQuotedMessageContent(
    message: Message,
    currentUser: User?,
    modifier: Modifier = Modifier,
    replyMessage: Message?,
) {
    val backgroundColor = Color.Black.copy(alpha = 0.05f)

    Row(modifier = modifier
        .clip(RoundedCornerShape(12.dp))
        .background(backgroundColor)
        .padding(end = 8.dp)
        .height(intrinsicSize = IntrinsicSize.Max)
    ) {
        Box(modifier = Modifier
            .width(4.dp)
            .fillMaxHeight()
            .background(color = getColorByHashingString(message.user.name))
        )

        Column(
            modifier = Modifier
                .padding(start = 8.dp, top = 8.dp, end = 0.dp, bottom = 8.dp)
                // .weight(1f)
        ) {
            val quotedMessageIsMine = message.user.id == currentUser?.id

            val senderName = if (quotedMessageIsMine) {
                stringResource(id = R.string.stream_compose_channel_list_you)
            } else {
                message.user.name
            }

            val replyIsMine = replyMessage?.user?.id == currentUser?.id

            val titleTextColor = if (replyIsMine) {
                CustomTheme.colorScheme.onPrimary
            } else {
                CustomTheme.colorScheme.onSurface
            }

            BasicText(
                text = senderName,
                modifier = Modifier.clipToBounds(),
                style = CustomTheme.typography.captionSmall.copy(color = titleTextColor),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )

            val bodyTextColor = if (replyIsMine) {
                CustomTheme.colorScheme.onPrimary.copy(alpha = 0.75f)
            } else {
                CustomTheme.colorScheme.onSurfaceSoft
            }

            val quotedMessagePreview = formatMessagePreview(
                message = message,
                showSenderName = false,
                isMine = null,
                isDirectMessageChannel = null
            )

            if (quotedMessagePreview != null) {
                BasicText(
                    text = quotedMessagePreview.annotatedString,
                    modifier = Modifier.clipToBounds(),
                    style = CustomTheme.typography.subhead.copy(color = bodyTextColor),
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    inlineContent = quotedMessagePreview.inlineContentMap
                )
            }
        }

        if (message.attachments.isNotEmpty()) {
            CustomQuotedMessageAttachmentContent(message = message)
        }
    }
}