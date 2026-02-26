package com.whoisup.app.stream

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.animateScrollBy
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.DcIcon
import com.whoisup.app.modifiers.layoutPadding
import com.whoisup.app.stream.viewModels.MessageSuggestionsViewModel
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import kotlinx.coroutines.launch

@Composable
fun RowScope.AmiMessageSuggestionCarousel(
    composerViewModel: MessageComposerViewModel,
    messageSuggestionsViewModel: MessageSuggestionsViewModel
) {
    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()
    val isProgrammaticallyScrolling = remember { mutableStateOf(false) }

    if (messageSuggestionsViewModel.hostReminderSuggestions.isEmpty()) {
        return
    }

    LazyRow(
        state = listState,
        contentPadding = PaddingValues(start = 28.dp, end = 28.dp),
        modifier = Modifier
            .fillMaxWidth()
            .weight(1f)
            // Add a bit of negative padding to visually slide this composable behind the "icebreaker"-button
            // We then also add some more contentPadding to offset for this negative padding
            .layoutPadding(horizontal = (-16).dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        userScrollEnabled = !isProgrammaticallyScrolling.value
    ) {
        itemsIndexed(messageSuggestionsViewModel.hostReminderSuggestions) { _, textId ->
            val text = stringResource(id = textId)
            AmiMessageSuggestionButton(
                text = text,
                onClick = {
                    coroutineScope.launch {
                        composerViewModel.setMessageInput(text)

                        val index = messageSuggestionsViewModel.hostReminderSuggestions.indexOf(textId)
                        if (index >= 0) {
                            isProgrammaticallyScrolling.value = true

                            val itemInfo = listState.layoutInfo.visibleItemsInfo.firstOrNull { it.index == index }
                            if (itemInfo != null) {
                                // Center of the viewport (LazyRow)
                                val viewportCenter = listState.layoutInfo.viewportEndOffset / 2
                                // Center of the item (offset is from the start of the viewport)
                                val itemCenter = itemInfo.offset + itemInfo.size / 2

                                // Scroll by the delta between item center and viewport center
                                val delta = (itemCenter - viewportCenter).toFloat()
                                listState.animateScrollBy(delta)
                            } else {
                                listState.animateScrollToItem(index)
                            }

                            isProgrammaticallyScrolling.value = false
                        }
                    }
                },
            )
        }
    }
}

@Composable
private fun AmiMessageSuggestionButton(
    text: String,
    onClick: () -> Unit,
) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(16.dp))
            .border(
                BorderStroke(2.dp, CustomTheme.colorScheme.primary),
                RoundedCornerShape(16.dp)
            )
            .clickable { onClick() }
            .padding(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        DcIcon(
            id = R.drawable.pencil,
            contentDescription = null,
            size = 12.dp,
            color = CustomTheme.colorScheme.primary
        )

        BasicText(
            text = text,
            style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.primary),
        )
    }
}
