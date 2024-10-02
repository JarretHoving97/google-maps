package com.whoisup.app.stream

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.whoisup.app.R
import com.whoisup.app.components.AmiBackButton
import com.whoisup.app.components.AmiEmptyContent
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.viewmodel.channels.ChannelListViewModel
import io.getstream.chat.android.compose.viewmodel.channels.ChannelViewModelFactory
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.FilterObject
import io.getstream.chat.android.models.Filters
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.User

fun Filters.customChannelListFilter(user: User?): FilterObject? {
    return if (user == null) {
        null
    } else {
        and(
            eq("type", "messaging"),
            `in`("members", listOf(user.id)),
            exists("last_message_at")
        )
    }
}

@Composable
fun AmiChannelsScreen(
    onChannelClick: (Channel) -> Unit,
    onMessageClick: (Message) -> Unit,
    onBackClick: () -> Unit,
) {
    BackHandler(enabled = true) {
        onBackClick()
    }

    val currentUser = ChatClient.instance().clientState.user.collectAsState().value

    val listViewModel: ChannelListViewModel = viewModel(
        ChannelListViewModel::class.java,
        key = null,
        factory = ChannelViewModelFactory(
            filters = Filters.customChannelListFilter(currentUser)
        ),
    )

    val singleChannelViewModel = viewModel(SingleChannelViewModel::class.java)

    var searchQuery by rememberSaveable { mutableStateOf("") }

    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(CustomTheme.colorScheme.background)
        ) {
            Column {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    AmiBackButton(onBackClick = onBackClick)

                    BasicText(
                        text = stringResource(id = R.string.AmiChannelsScreen_title),
                        style = CustomTheme.typography.heading.copy(color = CustomTheme.colorScheme.onBackground)
                    )

                    Spacer(modifier = Modifier.width(40.dp))
                }

                Box(
                    modifier = Modifier
                        .height(2.dp)
                        .fillMaxWidth()
                        .background(CustomTheme.colorScheme.surfaceHard)
                )
            }

//            val searchMode = SearchMode.Messages
//
//            AmiTextField(
//                value = searchQuery,
//                onValueChange = remember(listViewModel) {
//                    {
//                        searchQuery = it
//                        listViewModel.setSearchQuery(
//                            when {
//                                it.isBlank() -> SearchQuery.Empty
//                                searchMode == SearchMode.Channels -> SearchQuery.Channels(it)
//                                searchMode == SearchMode.Messages -> SearchQuery.Messages(it)
//                                else -> SearchQuery.Empty
//                            },
//                        )
//                    }
//                },
//                modifier = Modifier
//                    .padding(horizontal = 12.dp, vertical = 8.dp)
//                    .fillMaxWidth(),
//                singleLine = true,
//                leadingContent = {
//                    AmiIconButton(
//                        size = 40.dp,
//                        color = Color.Transparent,
//                        iconColor = CustomTheme.colorScheme.onBackground,
//                        iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_search,
//                    )
//                },
//                trailingContent = {
//                    if (searchQuery.isNotEmpty()) {
//                        AmiIconButton(
//                            size = 40.dp,
//                            color = CustomTheme.colorScheme.surfaceHard,
//                            iconColor = CustomTheme.colorScheme.onSurface,
//                            iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_clear,
//                            onClick = {
//                                searchQuery = ""
//                                listViewModel.setSearchQuery(SearchQuery.Empty)
//                            },
//                        )
//                    }
//                }
//            )

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                when {
                    listViewModel.channelsState.isLoading -> {
                        CircularProgressIndicator(
                            modifier = Modifier.align(Alignment.Center),
                            color = CustomTheme.colorScheme.primary,
                            strokeWidth = 2.dp
                        )
                    }

                    !listViewModel.channelsState.isLoading && listViewModel.channelsState.channelItems.isNotEmpty() -> AmiChannels(
                        listViewModel = listViewModel,
                        singleChannelViewModel = singleChannelViewModel,
                        currentUser = currentUser,
                        onChannelClick = onChannelClick,
                        onMessageClick = onMessageClick
                    )

                    listViewModel.channelsState.searchQuery.query.isNotBlank() -> {
                        AmiEmptyContent(
                            text = stringResource(io.getstream.chat.android.compose.R.string.stream_compose_channel_list_empty_search_results, searchQuery),
                            iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_empty_search_results
                        )
                    }

                    else -> {
                        AmiEmptyContent(
                            text = stringResource(io.getstream.chat.android.compose.R.string.stream_compose_channel_list_empty_channels),
                            iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_empty_channels
                        )
                    }
                }
            }
        }

        AmiChannelMenu(
            singleChannelViewModel = singleChannelViewModel,
            currentUser = currentUser,
        )
    }
}