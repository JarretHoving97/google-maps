package com.whoisup.app.stream

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.whoisup.app.R
import com.whoisup.app.components.AmiEmptyContent
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
import io.getstream.chat.android.state.extensions.getMessageUsingCache
import io.getstream.chat.android.ui.common.state.messages.MessageMode
import io.getstream.chat.android.ui.common.state.messages.ThreadReply
import io.getstream.result.Result

@Composable
fun AmiChannelThreadScreen(
    parentMessageId: String,
    viewModelFactory: MessagesViewModelFactory,
    onBackClick: () -> Unit,
    onUserAvatarClick: (String) -> Unit,
    onWalkthroughClick: (slideKey: String?) -> Unit,
    onContactSupportClick: () -> Unit,
) {
    val listViewModel = viewModel(MessageListViewModel::class.java, factory = viewModelFactory)
    val composerViewModel = viewModel(MessageComposerViewModel::class.java, factory = viewModelFactory)
    val attachmentsPickerViewModel = viewModel(AttachmentsPickerViewModel::class.java, factory = viewModelFactory)

    LaunchedEffect(parentMessageId) {
        /**
         * Get the parent message by id in a cache first manner.
         * Next perform the thread actions on the view models.
         * Alternately, this can be done by using the `MessagesViewModelFactory(messageId, parentMessageId)`,
         * but that strategy actually focuses on the parent message and scroll to the top.
         * That could be desirable (although it's a bit glitchy).
         * For now we chose the following strategy.
         */
        ChatClient.instance().getMessageUsingCache(parentMessageId).enqueue {
            when (it) {
                is Result.Success -> {
                    val action = ThreadReply(it.value)
                    listViewModel.performMessageAction(action)
                    composerViewModel.performMessageAction(action)
                }

                is Result.Failure -> {
                    onBackClick()
                }
            }
        }
    }

    val isImeVisible = WindowInsets.ime.getBottom(LocalDensity.current) > 0
    val backAction = remember(listViewModel, composerViewModel, attachmentsPickerViewModel) {
        {
            when {
                isImeVisible -> Unit

                attachmentsPickerViewModel.isShowingAttachments -> attachmentsPickerViewModel.changeAttachmentState(
                    false,
                )

                listViewModel.isShowingOverlay -> listViewModel.selectMessage(null)

                else -> onBackClick()
            }
        }
    }

    Box(modifier = Modifier.safeDrawingPadding().fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(CustomTheme.colorScheme.background)
        ) {
            BackHandler(enabled = true, onBack = backAction)

            AmiHeader(onBackClick = backAction)

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                val currentState = listViewModel.currentMessagesState

                when {
                    currentState.value.isLoading -> {
                        CircularProgressIndicator(
                            modifier = Modifier.align(Alignment.Center),
                            color = CustomTheme.colorScheme.primary,
                            strokeWidth = 2.dp
                        )
                    }

                    listViewModel.messageMode is MessageMode.MessageThread && currentState.value.messageItems.isNotEmpty() -> AmiChannelMessages(
                        listViewModel = listViewModel,
                        composerViewModel = composerViewModel,
                        onUserAvatarClick = onUserAvatarClick,
                        onWalkthroughClick = onWalkthroughClick
                    )

                    listViewModel.messageMode is MessageMode.MessageThread -> {
                        AmiEmptyContent(
                            text = stringResource(R.string.AmiChannelScreen_emptyState_group),
                            iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_empty_channels
                        )
                    }
                }
            }

            AmiChannelComposerContainer(
                listViewModel = listViewModel,
                composerViewModel = composerViewModel,
                attachmentsPickerViewModel = attachmentsPickerViewModel,
                onContactSupportClick = onContactSupportClick
            )
        }

        AmiChannelMenus(
            listViewModel = listViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            composerViewModel = composerViewModel,
        )
    }
}