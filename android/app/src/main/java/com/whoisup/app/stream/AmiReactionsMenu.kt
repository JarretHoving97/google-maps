package com.whoisup.app.stream

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.state.userreactions.UserReactionItemState
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.ui.common.state.messages.list.SelectedMessageReactionsState
import io.getstream.chat.android.ui.common.state.messages.list.SelectedMessageState

@Composable
fun AmiReactionsMenu(
    listViewModel: MessageListViewModel,
    selectedMessageState: SelectedMessageState?,
) {
    val selectedMessage = selectedMessageState?.message ?: Message()

    val visible = selectedMessageState is SelectedMessageReactionsState && selectedMessage.id.isNotEmpty()

    AmiSimpleMenu(
        visible = visible,
        onDismiss = remember(listViewModel) { { listViewModel.removeOverlay() } }
    ) {
        if (visible) {
            val reactions = selectedMessage.latestReactions
                .mapNotNull { reaction ->
                    val user = reaction.user

                    if (ChatTheme.reactionIconFactory.isReactionSupported(reaction.type) && user != null) {
                        // val isSelected = currentUser?.id == user.id
                        val painter = ChatTheme.reactionIconFactory.createReactionIcon(reaction.type).getPainter(false)

                        return@mapNotNull UserReactionItemState(
                            user = user,
                            painter = painter,
                            type = reaction.type,
                        )
                    }

                    return@mapNotNull null
                }

            if (reactions.isNotEmpty()) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .verticalScroll(rememberScrollState())
                        .clip(ChatTheme.shapes.bottomSheet)
                        .background(CustomTheme.colorScheme.background)
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    for (reaction in reactions) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            AmiAvatar(
                                user = UserForAmiAvatar(
                                    id = reaction.user.id,
                                    name = reaction.user.name,
                                    avatarUrl = reaction.user.image
                                ),
                            )

                            BasicText(
                                text = reaction.user.name,
                                modifier = Modifier.weight(1f),
                                style = CustomTheme.typography.caption.copy(color = CustomTheme.colorScheme.onBackground),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )

                            Image(
                                modifier = Modifier.size(16.dp),
                                painter = reaction.painter,
                                contentDescription = reaction.type,
                            )
                        }
                    }
                }
            }
        }
    }
}