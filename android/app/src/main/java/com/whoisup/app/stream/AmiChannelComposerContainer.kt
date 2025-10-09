package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiButton
import com.whoisup.app.stream.extensions.ChatChannelRelatedConceptType
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.stream.extensions.relatedConceptType
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.ChannelCapabilities

@Composable
fun AmiChannelComposerContainer(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
    onContactSupportClick: () -> Unit,
) {
    val currentUser by listViewModel.user.collectAsState()

    val otherUser = if (listViewModel.channel.isDirectMessageChannel()) {
        listViewModel.channel.members.firstOrNull {
            it.user.id != currentUser?.id
        }?.user
    } else {
        null
    }

    val messageComposerState by composerViewModel.messageComposerState.collectAsState()

    val canSendMessage = messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)

    if (otherUser?.isSupportTeamMember == true) {
        // You are not allowed to chat if the other user is part of our support team.
        Box(
            modifier = Modifier
                .height(2.dp)
                .fillMaxWidth()
                .background(CustomTheme.colorScheme.surfaceHard)
        )

        AmiButton(
            text = stringResource(id = com.whoisup.app.R.string.global_contact),
            onClick = onContactSupportClick,
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp)
        )
    } else if (!canSendMessage && listViewModel.channel.relatedConceptType is ChatChannelRelatedConceptType.Community) {
        // In this case we want to hide the composer entirely
    } else {
        AmiChannelComposer(
            listViewModel = listViewModel,
            composerViewModel = composerViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            enabled = canSendMessage
        )
    }
}