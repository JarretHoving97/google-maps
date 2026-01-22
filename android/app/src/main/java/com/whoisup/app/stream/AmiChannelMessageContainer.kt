package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.whoisup.app.stream.extensions.isAnonymousSystem
import com.whoisup.app.stream.extensions.isThreadStartOptimistic
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.ui.common.state.messages.list.DateSeparatorItemState
import io.getstream.chat.android.ui.common.state.messages.list.EmptyThreadPlaceholderItemState
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState
import io.getstream.chat.android.ui.common.state.messages.list.MessageListItemState
import io.getstream.chat.android.ui.common.state.messages.list.ModeratedMessageItemState
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
            // Instead we do this inside the `is MessageItemState`
        }
        is SystemMessageItemState -> {
            if (messageListItemState.message.isAnonymousSystem()) {
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
            val isInThreadAndStartOptimistic = messageListItemState.isInThread && messageListItemState.isThreadStartOptimistic()

            val modifier = if (isInThreadAndStartOptimistic) {
                Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp)
                    .background(CustomTheme.colorScheme.surfaceHard)
                    .padding(bottom = 2.dp)
                    .background(CustomTheme.colorScheme.surface)
                    .padding(vertical = 8.dp)
            } else {
                Modifier
            }

            Box(modifier = modifier) {
                AmiChannelMessageItem(
                    messageItem = messageListItemState,
                    listViewModel = listViewModel,
                    composerViewModel = composerViewModel,
                    onUserAvatarClick = onUserAvatarClick,
                    onWalkthroughClick = onWalkthroughClick,
                )
            }
        }
        is TypingItemState -> {
            // has no default stream implementation
        }
        is EmptyThreadPlaceholderItemState -> {
            // has no default stream implementation
        }
        is UnreadSeparatorItemState -> AmiChannelUnreadSeparator(messageListItemState)
        is StartOfTheChannelItemState -> {
            // has no default stream implementation
        }
        is ModeratedMessageItemState -> {
            // not implemented
        }
    }
}