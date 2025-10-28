package com.whoisup.app.stream

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.key
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.Reaction
import io.getstream.chat.android.ui.common.state.messages.React
import io.getstream.chat.android.ui.common.state.messages.updateMessage

@Composable
fun AmiReactionOptions(
    listViewModel: MessageListViewModel,
    composerViewModel: MessageComposerViewModel,
    selectedMessage: Message,
    modifier: Modifier = Modifier
) {
    val reactionTypes = ChatTheme.reactionIconFactory.createReactionIcons()

    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        reactionTypes.entries.forEach { reaction ->
            key(reaction.key) {
                val isSelected = selectedMessage.ownReactions.any { ownReaction -> ownReaction.type == reaction.key }
                val painter = reaction.value.getPainter(false)

                Image(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(if (isSelected) {
                            CustomTheme.colorScheme.surfaceHard
                        } else {
                            Color.Transparent
                        })
                        .clickable(
                            onClick = {
                                val action = React(
                                    reaction = Reaction(
                                        messageId = selectedMessage.id,
                                        type = reaction.key
                                    ),
                                    message = selectedMessage,
                                )

                                action
                                    .updateMessage(action.message)
                                    .let { messageAction ->
                                        composerViewModel.performMessageAction(messageAction)
                                        listViewModel.performMessageAction(messageAction)
                                    }
                            },
                        )
                        .padding(8.dp),
                    painter = painter,
                    contentDescription = reaction.key,
                )
            }
        }
    }
}