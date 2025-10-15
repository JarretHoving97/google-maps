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
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import com.whoisup.app.R
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.components.DcIcon
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.formatRelative
import com.whoisup.app.utils.getLocale
import io.getstream.chat.android.models.Option
import io.getstream.chat.android.models.Poll
import io.getstream.chat.android.models.Vote
import io.getstream.chat.android.models.VotingVisibility
import io.getstream.chat.android.ui.common.state.messages.poll.SelectedPoll
import java.time.ZoneId
import java.time.ZonedDateTime

@Composable
fun AmiPollViewResultDialog(
    selectedPoll: SelectedPoll,
    onDismissRequest: () -> Unit,
) {
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
            val poll = selectedPoll.poll

            BackHandler { onDismissRequest() }

            Column(modifier = Modifier
                .fillMaxSize()
                .background(CustomTheme.colorScheme.background)
            ) {
                AmiHeader(onBackClick = onDismissRequest)

                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    item {
                        BasicText(
                            text = poll.name,
                            style = CustomTheme.typography.headingLarge.copy(color = CustomTheme.colorScheme.onBackground)
                        )
                    }

                    val maxVoteCount = poll.voteCountsByOption.maxByOrNull { it.value }?.value ?: 0

                    val options = poll.options.sortedByDescending { option ->
                        poll.voteCountsByOption[option.id] ?: 0
                    }

                    items(
                        items = options,
                        key = { it.id },
                    ) { option ->
                        PollViewResultItem(
                            poll = poll,
                            option = option,
                            maxVoteCount = maxVoteCount,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun PollViewResultItem(
    poll: Poll,
    option: Option,
    maxVoteCount: Int
) {
    val votes = poll.votes
        .takeIf { poll.votingVisibility != VotingVisibility.ANONYMOUS }
        ?.filter { it.optionId == option.id } ?: emptyList()
    val votesCount = poll.voteCountsByOption[option.id] ?: votes.size

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(CustomTheme.colorScheme.surface)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            BasicText(
                text = option.text,
                modifier = Modifier.weight(1f),
                style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onSurface)
            )

            BasicText(
                text = pluralStringResource(
                    id = R.plurals.AmiPoll_votesCount,
                    count = votesCount,
                    votesCount
                ),
                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface)
            )

            if (maxVoteCount > 0 && maxVoteCount == votesCount) {
                DcIcon(
                    id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_award,
                    contentDescription = "favorite option icon",
                    size = 16.dp,
                    color = CustomTheme.colorScheme.onSurface
                )
            }
        }

        if (votes.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .height(1.dp)
                    .fillMaxWidth()
                    .background(CustomTheme.colorScheme.surfaceHard)
            )

            Spacer(modifier = Modifier.height(8.dp))

            votes.forEach { vote ->
                PollVoteItem(vote = vote)
            }

            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}

@Composable
private fun PollVoteItem(vote: Vote) {
    Row(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        vote.user?.let { user ->
            AmiAvatar(
                user = UserForAmiAvatar(
                    id = user.id,
                    name = user.name,
                    avatarUrl = user.image
                ),
                size = 44.dp,
            )

            Column {
                BasicText(
                    text = user.name,
                    style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onSurface)
                )

                BasicText(
                    text = formatRelative(
                        date = ZonedDateTime.ofInstant(
                            vote.createdAt.toInstant(),
                            ZoneId.systemDefault()
                        ),
                        locale = getLocale(),
                    ),
                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
                )
            }
        }
    }
}