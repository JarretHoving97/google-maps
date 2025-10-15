package com.whoisup.app.stream

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiRadioButtonIcon
import com.whoisup.app.components.BorderTheme
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.components.avatar.UserAvatarRow
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Option
import io.getstream.chat.android.models.Poll
import io.getstream.chat.android.models.VotingVisibility
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState
import io.getstream.chat.android.ui.common.state.messages.poll.PollSelectionType
import io.getstream.chat.android.ui.common.state.messages.poll.SelectedPoll

@Composable
fun PollMessageContent(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    poll: Poll
) {
    val textColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary
    } else {
        CustomTheme.colorScheme.onSurface
    }

    val actionTextColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary
    } else {
        CustomTheme.colorScheme.primary
    }

    Column(
        modifier = Modifier
            .padding(
                horizontal = 10.dp,
                vertical = 12.dp,
            ),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        BasicText(
            text = poll.name,
            style = CustomTheme.typography.captionSmall.copy(color = textColor),
        )

        poll.options.forEach { option ->
            PollOptionItem(
                messageItem = messageItem,
                listViewModel = listViewModel,
                poll = poll,
                option = option,
            )
        }

        BasicText(
            text = stringResource(id = R.string.AmiPoll_viewVotes),
            modifier = Modifier
                .fillMaxWidth()
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = {
                        listViewModel.displayPollMoreOptions(
                            selectedPoll = SelectedPoll(
                                poll,
                                messageItem.message,
                                PollSelectionType.ViewResult
                            )
                        )
                    }
                ),
            style = CustomTheme.typography.subhead.copy(
                color = actionTextColor,
                textAlign = TextAlign.Center
            ),
        )
    }
}

@Composable
private fun PollOptionItem(
    messageItem: MessageItemState,
    listViewModel: MessageListViewModel,
    poll: Poll,
    option: Option,
    modifier: Modifier = Modifier,
) {
    val voteCount = poll.voteCountsByOption[option.id] ?: 0
    val isVotedByMe = poll.ownVotes.any { it.optionId == option.id }
    val users = poll.votes.filter { it.optionId == option.id }.mapNotNull { it.user }
    val totalVoteCount = poll.voteCountsByOption.values.sum()
    val checkedCount = poll.ownVotes.count { it.optionId == option.id }

    val textColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary
    } else {
        CustomTheme.colorScheme.onSurface
    }

    val progressColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.background
    } else {
        CustomTheme.colorScheme.primary
    }

    val progressBackgroundColor = if (messageItem.isMine) {
        CustomTheme.colorScheme.onPrimary.copy(alpha = 0.2f)
    } else {
        CustomTheme.colorScheme.onBackground.copy(alpha = 0.1f)
    }

    Column(
        modifier = modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = {
                    if (checkedCount < poll.maxVotesAllowed && !isVotedByMe) {
                        listViewModel.castVote(
                            message = messageItem.message,
                            poll = poll,
                            option = option,
                        )
                    } else if (isVotedByMe) {
                        val vote = poll.ownVotes.firstOrNull { it.optionId == option.id }
                        if (vote != null) {
                            listViewModel.removeVote(
                                message = messageItem.message,
                                poll = poll,
                                vote = vote,
                            )
                        }
                    }
                }
            )
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (!poll.closed) {
                AmiRadioButtonIcon(
                    checked = isVotedByMe,
                    borderTheme = if (messageItem.isMine) {
                        BorderTheme.OnPrimary
                    } else {
                        BorderTheme.OnBackground
                    }
                )
            }

            BasicText(
                text = option.text,
                modifier = Modifier.weight(1f),
                style = CustomTheme.typography.subhead.copy(color = textColor),
                overflow = TextOverflow.Ellipsis,
                maxLines = 2,
            )

            if (voteCount > 0 && poll.votingVisibility != VotingVisibility.ANONYMOUS) {
                UserAvatarRow(users = users)
            }

            BasicText(
                text = voteCount.toString(),
                style = CustomTheme.typography.captionSmall.copy(color = textColor),
            )
        }

        val progress = if (voteCount == 0 || totalVoteCount == 0) {
            0f
        } else {
            voteCount / totalVoteCount.toFloat()
        }

        val animatedProgress by animateFloatAsState(
            targetValue = progress,
            label = "progress"
        )

        LinearProgressIndicator(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    start = if (poll.closed) {
                        0.dp
                    } else {
                        28.dp
                    },
                )
                .clip(RoundedCornerShape(2.dp))
                .height(8.dp),
            progress = animatedProgress,
            color = progressColor,
            backgroundColor = progressBackgroundColor,
        )
    }
}