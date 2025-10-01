package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.User
import io.getstream.chat.android.ui.common.state.messages.list.SystemMessageItemState

@Composable
fun AmiChannelSystemMessage(
    systemMessageState: SystemMessageItemState,
    currentUser: User?,
    onUserAvatarClick: (String) -> Unit
) {
    val isMine = systemMessageState.message.user.id == currentUser?.id

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 16.dp)
            .padding(horizontal = 12.dp),
        contentAlignment = if (isMine) {
            Alignment.CenterEnd
        } else {
            Alignment.CenterStart
        }
    ) {
        Row(
            modifier = Modifier
                .widthIn(max = 300.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CustomTheme.colorScheme.surfaceHard)
                .clickable {
                    onUserAvatarClick(systemMessageState.message.user.id)
                }
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AmiAvatar(
                user = UserForAmiAvatar(
                    id = systemMessageState.message.user.id,
                    name = systemMessageState.message.user.name,
                    avatarUrl = systemMessageState.message.user.image
                ),
                size = 44.dp,
            )

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Column {
                    BasicText(
                        text = systemMessageState.message.user.name,
                        style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface)
                    )

                    val text = formatSystemMessageText(systemMessageState.message)

                    BasicText(
                        text = text,
                        style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onSurface)
                    )
                }

                AmiMessageActionButton(message = systemMessageState.message)
            }
        }
    }
}