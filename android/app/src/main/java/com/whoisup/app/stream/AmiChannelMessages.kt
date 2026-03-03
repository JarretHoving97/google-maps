package com.whoisup.app.stream

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.stream.viewModels.MessageSuggestionsViewModel
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.messages.list.Messages
import io.getstream.chat.android.compose.ui.util.rememberMessageListState
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel

@Composable
fun AmiChannelMessages(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    messageSuggestionsViewModel: MessageSuggestionsViewModel? = null,
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
        footerContent = {
            if (messageSuggestionsViewModel?.hostReminderSuggestions?.isNotEmpty() == true || messageSuggestionsViewModel?.icebreakerSuggestions?.isNotEmpty() == true) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    AmiMessageSuggestionCarousel(
                        composerViewModel = composerViewModel,
                        messageSuggestionsViewModel = messageSuggestionsViewModel
                    )

                    val launcher = rememberLauncherForActivityResult(
                        contract = IcebreakerSuggestionsContract(),
                        onResult = {
                            if (it?.selectedIcebreakerSuggestionText !== null) {
                                composerViewModel.setMessageInput(it.selectedIcebreakerSuggestionText)
                            }
                        },
                    )

                    val context = LocalContext.current

                    if (messageSuggestionsViewModel.icebreakerSuggestions.isNotEmpty()) {
                        AmiIconButton(
                            size = 40.dp,
                            color = CustomTheme.colorScheme.primary,
                            iconColor = CustomTheme.colorScheme.onPrimary,
                            iconId = R.drawable.hammer,
                            onClick = {
                                launcher.launch(IcebreakerSuggestionsContract.Input(messageSuggestionsViewModel.icebreakerSuggestions.map { context.resources.getString(it) }))
                            }
                        )

                        Spacer(modifier = Modifier.width(12.dp))
                    }
                }
            }
        }
    )
}