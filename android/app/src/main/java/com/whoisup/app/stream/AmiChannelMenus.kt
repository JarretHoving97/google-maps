package com.whoisup.app.stream

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.AnimationConstants
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import io.getstream.chat.android.compose.ui.components.SimpleDialog
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.ui.common.state.messages.Delete
import io.getstream.chat.android.ui.common.state.messages.poll.PollSelectionType

@Composable
fun AmiChannelMenus(
    listViewModel: MessageListViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    val selectedMessageState = listViewModel.currentMessagesState.value.selectedMessageState
    val currentUser by listViewModel.user.collectAsState()

    AmiMessageMenu(
        listViewModel = listViewModel,
        composerViewModel = composerViewModel,
        selectedMessageState = selectedMessageState,
        currentUser = currentUser,
    )

    AmiReactionsMenu(
        listViewModel = listViewModel,
        selectedMessageState = selectedMessageState,
    )

    AttachmentsPickerMenu(
        listViewModel = listViewModel,
        attachmentsPickerViewModel = attachmentsPickerViewModel,
        composerViewModel = composerViewModel,
    )

    MessageDialogs(listViewModel = listViewModel)

    val selectedPoll = listViewModel.pollState.selectedPoll

    if (selectedPoll?.pollSelectionType == PollSelectionType.ViewResult) {
        AmiPollViewResultDialog(
            selectedPoll = selectedPoll,
            onDismissRequest = { listViewModel.displayPollMoreOptions(null) },
        )
    }

    // We don't need the following component,
    // because we do not have more than 5 reactions anyways
    // MessagesScreenReactionsPicker
}

@Composable
private fun AttachmentsPickerMenu(
    listViewModel: MessageListViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    val isShowingAttachments = attachmentsPickerViewModel.isShowingAttachments

    AnimatedVisibility(
        visible = isShowingAttachments,
        enter = fadeIn(),
        exit = fadeOut(animationSpec = tween(delayMillis = AnimationConstants.DefaultDurationMillis / 2)),
    ) {
        AmiAttachmentsPicker(
            listViewModel = listViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            composerViewModel = composerViewModel
        )
    }
}

@Composable
private fun MessageDialogs(listViewModel: MessageListViewModel) {
    val messageActions = listViewModel.messageActions

    val deleteAction = messageActions.firstOrNull { it is Delete }

    if (deleteAction != null) {
        SimpleDialog(
            modifier = Modifier.padding(16.dp),
            title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_delete_message_title),
            message = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_delete_message_text),
            onPositiveAction = remember(listViewModel) { { listViewModel.deleteMessage(deleteAction.message) } },
            onDismiss = remember(listViewModel) { { listViewModel.dismissMessageAction(deleteAction) } },
        )
    }
}