package com.whoisup.app

import android.os.Bundle
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.stream.IcebreakerSuggestionsContract
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.enableEdgeToEdgeCustom

class IcebreakerSuggestionsActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdgeCustom()

        val activity = this

        val input = IcebreakerSuggestionsContract.parseIntent(activity)

        val suggestions = input?.suggestions ?: listOf()

        setContent {
            CustomTheme {
                val pagerState = rememberPagerState(
                    initialPage = 0,
                    pageCount = { suggestions.size }
                )

                Box(modifier = Modifier.safeDrawingPadding().fillMaxSize()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(CustomTheme.colorScheme.background)
                    ) {
                        val onDismissRequest = {
                            finish()
                        }

                        BackHandler { onDismissRequest() }

                        AmiHeader(
                            title = stringResource(R.string.AmiIcebreakers_title),
                            onBackClick = onDismissRequest
                        )

                        Box(modifier = Modifier.weight(1f)) {
                            Column(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .verticalScroll(rememberScrollState())
                                    .height(IntrinsicSize.Min) // make sure to stretch parent to fit the pager
                                    .padding(start = 16.dp, top = 16.dp, end = 16.dp),
                                verticalArrangement = Arrangement.spacedBy(16.dp)
                            ) {
                                BasicText(
                                    text = stringResource(R.string.AmiIcebreakers_body),
                                    style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground)
                                )

                                IcebreakerSuggestionsPager(pagerState, suggestions)
                            }
                        }

                        AmiButton(
                            text = stringResource(R.string.AmiIcebreakers_submit),
                            onClick = {
                                IcebreakerSuggestionsContract.createResult(
                                    activity = activity,
                                    result = IcebreakerSuggestionsContract.Result(
                                        selectedIcebreakerSuggestionText = suggestions[pagerState.currentPage]
                                    )
                                )
                            },
                            modifier = Modifier
                                .padding(16.dp)
                                .fillMaxWidth(),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ColumnScope.IcebreakerSuggestionsPager(
    pagerState: PagerState,
    suggestions: List<String>
) {
    HorizontalPager(
        modifier = Modifier
            .height(200.dp) // min height
            .weight(1f) // This makes the composable fill the height of the scrollable parent. But it also makes it shrink. So we need the `height` modifier as well.
            .verticalScroll(rememberScrollState()) // Better safe than sorry. It could happen that 200.dp is still too little.
            .clip(RoundedCornerShape(8.dp))
            .background(CustomTheme.colorScheme.surfaceHard),
        contentPadding = PaddingValues(64.dp),
        pageSpacing = 64.dp,
        state = pagerState,
        beyondViewportPageCount = 2,
        verticalAlignment = Alignment.CenterVertically
    ) { page ->
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            BasicText(
                text = suggestions[page],
                modifier = Modifier
                    .clip(
                        RoundedCornerShape(
                            topStart = 16.dp,
                            topEnd = 16.dp,
                            bottomStart = 16.dp,
                            bottomEnd = 3.dp
                        )
                    )
                    .background(CustomTheme.colorScheme.primary)
                    .clickable { }
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onPrimary),
            )
        }
    }

    PagerIndicator(pagerState)
}

@Composable
private fun ColumnScope.PagerIndicator(pagerState: PagerState) {
    Row(
        Modifier
            .fillMaxWidth()
            .wrapContentSize()
            .align(Alignment.CenterHorizontally),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        repeat(pagerState.pageCount) { index ->
            val color = if (pagerState.currentPage == index) {
                CustomTheme.colorScheme.primary
            } else {
                CustomTheme.colorScheme.surfaceHard
            }
            Box(
                modifier = Modifier
                    .clip(CircleShape)
                    .background(color)
                    .size(8.dp)
            )
        }
    }
}