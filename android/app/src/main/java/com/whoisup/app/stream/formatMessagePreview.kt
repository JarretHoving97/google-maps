package com.whoisup.app.stream

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.InlineTextContent
import androidx.compose.foundation.text.appendInlineContent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.Placeholder
import androidx.compose.ui.text.PlaceholderVerticalAlign
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.whoisup.app.R
import com.whoisup.app.helpers.customLinkify
import com.whoisup.app.helpers.customLinkifyWithMarkdown
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.utils.message.isDeleted
import io.getstream.chat.android.client.utils.message.isSystem
import io.getstream.chat.android.models.Message

data class MessagePreview(val annotatedString: AnnotatedString, val inlineContentMap: Map<String, InlineTextContent>)

class AttachmentContent(@DrawableRes val iconId: Int, val description: String)

@Composable
fun formatSystemMessageText(
    message: Message,
): String {
    val translationKey = message.extraData["translationKey"] as? String

    @StringRes val resourceId = when (translationKey) {
        MessageTranslationKeyEnum.AttendanceReminder.value -> {
            R.string.AmiChannelSystemMessage_AttendenceReminder
        }
        MessageTranslationKeyEnum.GroupChatCreated.value -> {
            R.string.AmiChannelSystemMessage_GroupChatCreated
        }
        MessageTranslationKeyEnum.GroupChatJoined.value -> {
            R.string.AmiChannelSystemMessage_GroupChatJoined
        }
        MessageTranslationKeyEnum.RepeatActivity.value -> {
            R.string.AmiChannelSystemMessage_RepeatActivity
        }
        else -> {
            null
        }
    }

    return if (resourceId != null) {
        stringResource(id = resourceId, message.user.name)
    } else {
        message.text
    }
}

@Composable
fun formatMessagePreview(
    message: Message,
    showSenderName: Boolean,
    /**
     * Only allowed to be `null` if `showSenderName == false`
     */
    isMine: Boolean?,
    /**
     * Only allowed to be `null` if `showSenderName == false`
     */
    isDirectMessageChannel: Boolean?
): MessagePreview? {
    val inlineContentMap: MutableMap<String, InlineTextContent> = mutableMapOf()

    val annotatedString = buildAnnotatedString {
        if (message.isDeleted()) {
            append(stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_message_deleted))
        } else if (message.isSystem()) {
            append(formatSystemMessageText(message))
        } else {
            val attachmentContent = findFirstAttachmentWithFactory(message)?.let {
                it.factory.previewText.invoke(it.attachment)
            }

            if (attachmentContent != null) {
                appendInlineContent(id = "imageId")

                inlineContentMap["imageId"] = InlineTextContent(
                    Placeholder(15.sp, 11.sp, PlaceholderVerticalAlign.TextCenter)
                ) {
                    Image(
                        painter = painterResource(attachmentContent.iconId),
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(end = 4.dp),
                        contentDescription = "",
                        colorFilter = ColorFilter.tint(CustomTheme.colorScheme.onSurfaceSoft)
                    )
                }
            }

            if (showSenderName) {
                val senderName = if (isMine == true) {
                    stringResource(id = R.string.stream_compose_channel_list_you)
                } else if (isDirectMessageChannel == false) {
                    message.user.name
                } else {
                    null
                }

                senderName.takeIf { !it.isNullOrBlank() }?.let {
                    append("${it}: ")
                }
            }

            val linkifiedText = remember(message.text, message.user.role) {
                if (message.user.isSupportTeamMember) {
                    message.text.customLinkifyWithMarkdown(SpanStyle(), addAnnotations = false)
                } else {
                    message.text.customLinkify(SpanStyle())
                }
            }
            append(linkifiedText)

            if (message.text.isBlank() && attachmentContent != null) {
                append(attachmentContent.description)
            }
        }
    }

    if (annotatedString.isNotEmpty()) {
        return MessagePreview(
            annotatedString = annotatedString,
            inlineContentMap = inlineContentMap
        )
    }

    return null
}