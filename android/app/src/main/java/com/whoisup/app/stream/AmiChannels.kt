package com.whoisup.app.stream

import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import io.getstream.chat.android.compose.state.channels.list.ItemState
import io.getstream.chat.android.compose.ui.channels.list.Channels
import io.getstream.chat.android.compose.viewmodel.channels.ChannelListViewModel
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.User

@Composable
fun AmiChannels(
    listViewModel: ChannelListViewModel,
    singleChannelViewModel: SingleChannelViewModel,
    currentUser: User?,
    onChannelClick: (Channel) -> Unit,
    onMessageClick: (Message) -> Unit
) {
    Channels(
        // modifier = modifier,
        // contentPadding = contentPadding,
        channelsState = listViewModel.channelsState,
        lazyListState = rememberLazyListState(),
        onLastItemReached = remember(listViewModel) { { listViewModel.loadMore() } },
        helperContent = { /* We're not using this */ },
        // loadingMoreContent = loadingMoreContent,
        itemContent = { itemState ->
            when (itemState) {
                is ItemState.ChannelItemState -> AmiChannelItem(
                    itemState = itemState,
                    singleChannelViewModel = singleChannelViewModel,
                    currentUser = currentUser,
                    onChannelClick = onChannelClick
                )
                is ItemState.SearchResultItemState -> AmiSearchResultItem(
                    itemState = itemState,
                    currentUser = currentUser,
                    onMessageClick = onMessageClick
                )
            }
        },
        divider = {},
    )
}