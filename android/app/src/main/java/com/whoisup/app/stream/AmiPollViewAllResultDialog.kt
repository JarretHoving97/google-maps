package com.whoisup.app.stream

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.viewModel
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.handlers.LoadMoreHandler
import io.getstream.chat.android.compose.ui.components.LoadingIndicator
import io.getstream.chat.android.core.internal.InternalStreamChatApi
import io.getstream.chat.android.models.Option
import io.getstream.chat.android.models.Poll
import io.getstream.chat.android.ui.common.feature.messages.poll.PollOptionVotesViewAction
import io.getstream.chat.android.ui.common.feature.messages.poll.PollOptionVotesViewController
import io.getstream.chat.android.ui.common.feature.messages.poll.PollOptionVotesViewEvent
import io.getstream.chat.android.ui.common.state.messages.poll.PollOptionVotesViewState
import io.getstream.chat.android.ui.common.state.messages.poll.SelectedPoll
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * This composable is copy-paste from Streams SDK as its marked internal there
 */
@Composable
internal fun ViewModelStore(
    vararg keys: Any?,
    content: @Composable () -> Unit,
) {
    // Create a fresh ViewModelStore on each new composition
    val viewModelStore = remember { ViewModelStore() }
    val viewModelStoreOwner = remember(viewModelStore) {
        object : ViewModelStoreOwner {
            override val viewModelStore: ViewModelStore = viewModelStore
        }
    }

    // Clear the store when the composition is disposed
    DisposableEffect(keys) {
        onDispose {
            viewModelStore.clear()
        }
    }

    CompositionLocalProvider(LocalViewModelStoreOwner provides viewModelStoreOwner) {
        content()
    }
}

/**
 * This class is copy-paste from Streams SDK as its marked internal there
 */
@OptIn(InternalStreamChatApi::class)
internal class PollOptionVotesViewModel(
    poll: Poll,
    option: Option,
    controllerProvider: ViewModel.() -> PollOptionVotesViewController = {
        PollOptionVotesViewController(
            poll = poll,
            option = option,
            scope = viewModelScope,
        )
    },
) : ViewModel() {

    private val controller: PollOptionVotesViewController by lazy { controllerProvider() }

    /**
     * @see [PollOptionVotesViewController.state]
     */
    val state: StateFlow<PollOptionVotesViewState> = controller.state

    /**
     * @see [PollOptionVotesViewController.events]
     */
    val events: SharedFlow<PollOptionVotesViewEvent> = controller.events

    /**
     * @see [PollOptionVotesViewController.onViewAction]
     */
    fun onViewAction(action: PollOptionVotesViewAction) {
        controller.onViewAction(action)
    }
}

@OptIn(InternalStreamChatApi::class)
@Composable
fun AmiPollViewAllResultDialog(
    selectedPoll: SelectedPoll,
    selectedOptionId: String,
    onDismissRequest: () -> Unit,
) {
    val poll = selectedPoll.poll
    val selectedOption = selectedPoll.poll.options.firstOrNull { it.id == selectedOptionId }

    val state = remember {
        MutableTransitionState(false).apply {
            // Start the animation immediately.
            targetState = true
        }
    }
    Popup(
        alignment = Alignment.BottomCenter,
        onDismissRequest = onDismissRequest,
    ) {
        AnimatedVisibility(
            visibleState = state,
            enter = fadeIn() + slideInVertically(
                animationSpec = tween(400),
                initialOffsetY = { fullHeight -> fullHeight / 2 },
            ),
            exit = fadeOut(animationSpec = tween(200)) +
                    slideOutVertically(animationSpec = tween(400)),
            label = "poll view result dialog",
        ) {
            if (selectedOption != null) {
                BackHandler { onDismissRequest() }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(CustomTheme.colorScheme.background)
                ) {
                    AmiHeader(onBackClick = onDismissRequest)

                    PollOptionHeader(poll, selectedOption)

                    Box(
                        modifier = Modifier
                            .height(1.dp)
                            .fillMaxWidth()
                            .background(CustomTheme.colorScheme.surfaceHard)
                    )

                    ViewModelStore {
                        val viewModel = viewModel {
                            PollOptionVotesViewModel(
                                poll = poll,
                                option = selectedOption,
                            )
                        }

                        val state by viewModel.state.collectAsState()

                        val listState = rememberLazyListState()

                        LoadMoreHandler(
                            lazyListState = listState,
                            loadMore = { viewModel.onViewAction(PollOptionVotesViewAction.LoadMoreRequested) },
                        )

                        LazyColumn(
                            state = listState,
                            contentPadding = PaddingValues(vertical = 16.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            items(
                                items = state.results,
                                key = { it.id },
                            ) { vote ->
                                PollVoteItem(vote = vote)
                            }

                            if (state.isLoadingMore) {
                                item {
                                    LoadingIndicator(modifier = Modifier.fillMaxWidth())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}