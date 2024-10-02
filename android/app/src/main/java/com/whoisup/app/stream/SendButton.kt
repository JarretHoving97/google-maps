package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.ui.common.state.messages.composer.ValidationError

@Composable
fun SendButton(
    value: String,
    attachments: List<Attachment>,
    validationErrors: List<ValidationError>,
    ownCapabilities: Set<String>,
    onSendMessage: (String, List<Attachment>) -> Unit,
) {
    val isSendButtonEnabled = ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)
    val isInputValid by lazy { (value.isNotBlank() || attachments.isNotEmpty()) && validationErrors.isEmpty() }

    // @TODO: mirror rtl(?)
    AmiIconButton(
        size = 40.dp,
        color = if (isSendButtonEnabled && isInputValid) {
            CustomTheme.colorScheme.primary
        } else {
            CustomTheme.colorScheme.surface
        },
        iconColor = if (isSendButtonEnabled && isInputValid) {
            CustomTheme.colorScheme.onPrimary
        } else {
            CustomTheme.colorScheme.onSurfaceSoft
        },
        iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_send,
        onClick = {
            if (isSendButtonEnabled && isInputValid) {
                onSendMessage(value, attachments)
            }
        },
    )
}