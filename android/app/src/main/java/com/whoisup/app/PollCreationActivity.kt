package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.listSaver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiButtonTheme
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.components.AmiSimpleDialogDrawer
import com.whoisup.app.components.AmiSwitch
import com.whoisup.app.components.AmiTextField
import com.whoisup.app.components.DcIcon
import com.whoisup.app.stream.PollCreationResult
import com.whoisup.app.ui.theme.CustomTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import sh.calvin.reorderable.ReorderableItem
import sh.calvin.reorderable.rememberReorderableLazyListState
import java.util.UUID

internal const val MAX_OPTIONS = 10

class PollCreationActivity : BaseComponentActivity() {
    private val viewModel: PollCreationViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            CustomTheme {
                Box(modifier = Modifier.fillMaxSize()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(CustomTheme.colorScheme.background)
                    ) {
                        val state by viewModel.state.collectAsState()

                        var isShowingDiscardDialog by rememberSaveable { mutableStateOf(false) }

                        AmiSimpleDialogDrawer(
                            showDialog = isShowingDiscardDialog,
                            onDismissRequest = { isShowingDiscardDialog = false },
                            useSlideAnimation = false
                        ) {
                            if (isShowingDiscardDialog) {
                                Column(
                                    modifier = Modifier
                                        .padding(16.dp)
                                        .fillMaxWidth()
                                        .widthIn(400.dp)
                                        .align(Alignment.Center)
                                        .pointerInput(Unit) {}
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(CustomTheme.colorScheme.background)
                                        .padding(24.dp),
                                    verticalArrangement = Arrangement.spacedBy(8.dp),
                                ) {
                                    BasicText(
                                        text = stringResource(R.string.AmiPoll_leavePoll_title),
                                        style = CustomTheme.typography.heading.copy(color = CustomTheme.colorScheme.onBackground)
                                    )

                                    BasicText(
                                        text = stringResource(R.string.AmiPoll_leavePoll_body),
                                        style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground)
                                    )

                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(top = 8.dp),
                                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    ) {
                                        AmiButton(
                                            text = stringResource(R.string.AmiPoll_leavePoll_keepEditing),
                                            onClick = {
                                                isShowingDiscardDialog = false
                                            },
                                            modifier = Modifier.weight(1f),
                                            theme = AmiButtonTheme(
                                                color = CustomTheme.colorScheme.primary,
                                                textColor = CustomTheme.colorScheme.primary,
                                                filled = false
                                            )
                                        )

                                        AmiButton(
                                            text = stringResource(R.string.AmiPoll_leavePoll_leave),
                                            onClick = {
                                                isShowingDiscardDialog = false
                                                handleResult(null)
                                            },
                                            modifier = Modifier.weight(1f),
                                            theme = AmiButtonTheme(
                                                color = CustomTheme.colorScheme.danger,
                                                textColor = CustomTheme.colorScheme.onDanger,
                                            )
                                        )
                                    }
                                }
                            }
                        }

                        val onDismissRequest = {
                            val hasChanges = state.question.isNotBlank() || state.options.any { it.isNotBlank() }
                            if (hasChanges) {
                                isShowingDiscardDialog = true
                            } else {
                                finish()
                            }
                        }

                        BackHandler { onDismissRequest() }

                        AmiHeader(onBackClick = onDismissRequest)

                        Box(modifier = Modifier.weight(1f)) {
                            Column(
                                modifier = Modifier
                                    .verticalScroll(rememberScrollState())
                                    .padding(16.dp),
                                verticalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                BasicText(
                                    text = stringResource(R.string.AmiPoll_question_label),
                                    style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onBackground)
                                )

                                AmiTextField(
                                    value = state.question,
                                    onValueChange = { viewModel.setQuestion(it) },
                                    placeholder = stringResource(R.string.AmiPoll_question_placeholder),
                                    singleLine = true,
                                )

                                Spacer(modifier = Modifier.height(8.dp))

                                BasicText(
                                    text = stringResource(R.string.AmiPoll_options_label),
                                    style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onBackground)
                                )

                                PollOptionList(viewModel = viewModel)

                                Spacer(modifier = Modifier.height(8.dp))

                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(12.dp))
                                        .clickable(
                                            onClick = {
                                                viewModel.setMultipleVotesAllowed(!state.multipleVotesAllowed)
                                            }
                                        )
                                        .background(CustomTheme.colorScheme.surface)
                                        .padding(16.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    BasicText(
                                        text = stringResource(R.string.AmiPoll_allowMultipleAnswers),
                                        style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onBackground)
                                    )

                                    Spacer(modifier = Modifier.width(8.dp))

                                    AmiSwitch(checked = state.multipleVotesAllowed, onCheckedChange = { viewModel.setMultipleVotesAllowed(it) })
                                }
                            }
                        }

                        AmiButton(
                            text = stringResource(R.string.stream_compose_send),
                            onClick = {
                                handleResult(
                                    result = PollCreationResult(
                                        question = viewModel.state.value.question.trim(),
                                        options = viewModel.state.value.options.map { it.trim() },
                                        multipleVotesAllowed = viewModel.state.value.multipleVotesAllowed,
                                    )
                                )
                            },
                            modifier = Modifier
                                .padding(16.dp)
                                .fillMaxWidth(),
                            enabled = state.question.isNotBlank() && state.options.distinctBy { it.trim() }.filter { it.isNotBlank() }.size >= 2
                        )
                    }
                }
            }
        }
    }

    private fun handleResult(result: PollCreationResult?) {
        if (result != null) {
            val data = Intent().apply {
                putExtra(KeyResult, result)
            }
            setResult(RESULT_OK, data)
        } else {
            setResult(RESULT_CANCELED)
        }
        finish()
    }

    companion object {
        const val KeyResult: String = "pollCreationResult"

        fun getIntent(
            context: Context,
        ): Intent {
            return Intent(context, PollCreationActivity::class.java)
        }
    }
}

class PollCreationViewModel: ViewModel() {
    private val uiState = MutableStateFlow(PollCreationState())
    val state: StateFlow<PollCreationState> = uiState

    fun setQuestion(value: String) {
        uiState.update { it.copy(question = value) }
    }

    fun setOptions(value: List<String>) {
        uiState.update { it.copy(options = value) }
    }

    fun setMultipleVotesAllowed(value: Boolean) {
        uiState.update { it.copy(multipleVotesAllowed = value) }
    }
}

interface PollCreationData {
    val question: String
    val options: List<String>
    val multipleVotesAllowed: Boolean
}

data class PollCreationState(
    override val question: String = "",
    override val options: List<String> = listOf(),
    override val multipleVotesAllowed: Boolean = false
) : PollCreationData

@Immutable
data class PollOptionItem(
    val title: String,
    val key: String = UUID.randomUUID().toString(),
)

@Composable
fun PollOptionList(viewModel: PollCreationViewModel) {
    val lazyListState: LazyListState = rememberLazyListState()

    var optionItemList by rememberSaveable(
        // We need a custom saver because it's a list of custom classes
        saver = listSaver(
            save = {
                it.value.map { item -> item.title }
            },
            restore = {
                mutableStateOf(it.map { title -> PollOptionItem(title = title) })
            }
        )
    ) {
        mutableStateOf(listOf(PollOptionItem(title = "")))
    }

    val duplicateOptionItemKeys = remember(optionItemList) {
        optionItemList
            // Group by trimmed title to be able to count duplicates
            .groupBy { it.title.trim() }
            // Filter groups with more than one item (i.e., duplicates)
            .filter { it.value.size > 1 && it.key.isNotBlank() }
            // Flatten the list of items in each group and extract their keys
            .flatMap { it.value.map { item -> item.key } }
            // Convert to a set
            .toSet()
    }

    LaunchedEffect(optionItemList) {
        // Everytime the options change,
        // we want to delegate those options to the viewmodel
        // (so we can create the poll later on)
        // We want to filter out empty/blank options though
        viewModel.setOptions(optionItemList.mapNotNull {
            if (it.title.isNotBlank()) {
                return@mapNotNull it.title
            }
            return@mapNotNull null
        })
    }

    val reorderableLazyListState = rememberReorderableLazyListState(lazyListState = lazyListState) { from, to ->
        // This is the magic for actually updating the order of the list
        optionItemList = optionItemList.toMutableList().apply {
            add(to.index, removeAt(from.index))
        }
    }

    // `maxHeight` is a workaround to nest a `LazyColumn` inside a scrollable `Column` without knowing both heights upfront.
    // In this case we know for sure there will be no more than `MAX_OPTIONS` items.
    // Those items will not be higher than 100.dp each.
    val maxHeight = (MAX_OPTIONS * 100).dp

    LazyColumn(
        modifier = Modifier.heightIn(max = maxHeight),
        state = lazyListState,
        verticalArrangement = Arrangement.spacedBy(8.dp),
        userScrollEnabled = true, // Just in case the `maxHeight` is not high enough, a user can still scroll inside the nest `LazyColumn`
    ) {
        itemsIndexed(optionItemList, key = { _, item -> item.key }) { index, item ->
            ReorderableItem(reorderableLazyListState, key = item.key, enabled = item.title.isNotBlank()) { _ ->
                AmiTextField(
                    value = item.title,
                    onValueChange = { newTitle ->
                        // Update this title into the list
                        optionItemList = optionItemList.toMutableList().apply {
                            this[index] = item.copy(title = newTitle)
                        }

                        // If there are no more blank options after typing in this field,
                        // we want to add another empty option, which will serve as a "+ Add"-button
                        // But only if the max number of options isn't reached yet.
                        if (optionItemList.none { it.title.isBlank() } && optionItemList.size < MAX_OPTIONS) {
                            optionItemList = optionItemList.toMutableList().apply {
                                add(PollOptionItem(title = ""))
                            }
                        }
                    },
                    placeholder = stringResource(R.string.AmiPoll_option_placeholder),
                    singleLine = true,
                    onFocusChange = {
                        // Upon changing focus (mainly blurring/defocusing) we want to
                        // remove all blank options, except the last one (which - again - serves as the "+ Add"-button)
                        val lastIndex = optionItemList.indexOfLast {
                            it.title.isBlank()
                        }
                        optionItemList = optionItemList.toMutableList().apply {
                            optionItemList.forEachIndexed { index, pollOptionItem ->
                                if (pollOptionItem.title.isBlank() && index != lastIndex) {
                                    removeAt(index)
                                }
                            }
                        }
                    },
                    headingContent = {
                        val paddingValues = PaddingValues(start = 8.dp, top = 8.dp, end = 8.dp)

                        AnimatedVisibility(visible = duplicateOptionItemKeys.contains(item.key)) {
                            BasicText(
                                text = stringResource(R.string.AmiPoll_optionAlreadyExists),
                                modifier = Modifier.padding(paddingValues),
                                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.danger)
                            )
                        }
                    },
                    trailingContent = {
                        // Only if the option is actually not blank, we want to show the drag handle
                        if (item.title.isNotBlank()) {
                            DcIcon(
                                id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_drag_handle,
                                contentDescription = null,
                                size = 16.dp,
                                modifier = Modifier
                                    .padding(8.dp)
                                    .draggableHandle(),
                            )
                        }
                    }
                )
            }
        }
    }
}