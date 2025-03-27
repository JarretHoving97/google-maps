package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.ui.common.state.messages.list.DateSeparatorItemState
import io.getstream.chat.android.ui.common.state.messages.list.EmptyThreadPlaceholderItemState
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState
import io.getstream.chat.android.ui.common.state.messages.list.MessageListItemState
import io.getstream.chat.android.ui.common.state.messages.list.StartOfTheChannelItemState
import io.getstream.chat.android.ui.common.state.messages.list.SystemMessageItemState
import io.getstream.chat.android.ui.common.state.messages.list.ThreadDateSeparatorItemState
import io.getstream.chat.android.ui.common.state.messages.list.TypingItemState
import io.getstream.chat.android.ui.common.state.messages.list.UnreadSeparatorItemState

@Composable
fun AmiChannelMessageContainer(
    messageListItemState: MessageListItemState,
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    onUserAvatarClick: (String) -> Unit,
    onWalkthroughClick: (slideKey: String?) -> Unit,
) {
    val currentUser by listViewModel.user.collectAsState()

    when (messageListItemState) {
        is DateSeparatorItemState -> AmiChannelDateSeparator(messageListItemState)
        is ThreadDateSeparatorItemState -> {
            /* we're not using threaded messages */
        }
        is SystemMessageItemState -> {
            val layoutKey = messageListItemState.message.extraData["layoutKey"] as? String
            if (layoutKey == MessageLayoutKeyEnum.Anonymous.value) {
                AmiChannelAnonymousSystemMessage(
                    systemMessageState = messageListItemState,
                )
            } else {
                AmiChannelSystemMessage(
                    systemMessageState = messageListItemState,
                    currentUser = currentUser,
                    onUserAvatarClick = onUserAvatarClick
                )
            }
        }
        is MessageItemState -> {
            AmiChannelMessageItem(
                messageItem = messageListItemState,
                listViewModel = listViewModel,
                composerViewModel = composerViewModel,
                onUserAvatarClick = onUserAvatarClick,
                onWalkthroughClick = onWalkthroughClick,
            )
        }
        is TypingItemState -> {
            // has no default stream implementation
        }
        is EmptyThreadPlaceholderItemState -> {
            /* we're not using threaded messages */
            // has no default stream implementation
        }
        is UnreadSeparatorItemState -> AmiChannelUnreadSeparator(messageListItemState)
        is StartOfTheChannelItemState -> {
            // has no default stream implementation
        }
    }
}