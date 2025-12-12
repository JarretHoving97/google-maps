package com.whoisup.app.stream

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import io.getstream.chat.android.compose.ui.messages.list.Messages
import io.getstream.chat.android.compose.ui.util.rememberMessageListState
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel

@Composable
fun AmiChannelMessages(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    contentPaddingTop: Dp = 0.dp,
    onUserAvatarClick: (String) -> Unit,
    onWalkthroughClick: (slideKey: String?) -> Unit,
) {
    val currentState = listViewModel.currentMessagesState

    Messages(
        contentPadding = PaddingValues(
            // only add extra padding if needed (e.g. for PinnedMessage and SafetyCheck components)
            top = contentPaddingTop,
            bottom = 16.dp
        ),
        messagesState = currentState.value,
        messagesLazyListState = rememberMessageListState(parentMessageId = currentState.value.parentMessageId),
        verticalArrangement = Arrangement.Bottom,
        threadsVerticalArrangement = Arrangement.Top,
        onMessagesStartReached = { listViewModel.loadOlderMessages() },
        onLastVisibleMessageChanged = { listViewModel.updateLastSeenMessage(it) },
        onScrolledToBottom = { listViewModel.clearNewMessageState() },
//                helperContent = {
//                    // @TODO: this button doesn't look quite like how we would design it,
//                    // but the business logic inside is not something you would want to duplicate
//                },
//                loadingMoreContent = {
//                    // @TODO
//                },
        itemContent = {
            AmiChannelMessageContainer(
                messageListItemState = it,
                listViewModel = listViewModel,
                composerViewModel = composerViewModel,
                onUserAvatarClick = onUserAvatarClick,
                onWalkthroughClick = onWalkthroughClick
            )
        },
        onMessagesEndReached = { listViewModel.loadNewerMessages(it) /* listViewModel.onBottomEndRegionReached(it) */ },
        onScrollToBottom = { listViewModel.scrollToBottom(scrollToBottom = it) },
    )
}