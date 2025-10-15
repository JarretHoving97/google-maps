package com.whoisup.app.stream

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.formatRelative
import com.whoisup.app.utils.getLocale
import io.getstream.chat.android.compose.state.channels.list.ItemState
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.models.User
import java.time.ZoneId
import java.time.ZonedDateTime

@Composable
fun AmiSearchResultItem(
    itemState: ItemState.SearchResultItemState,
    currentUser: User?,
    onMessageClick: (Message) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight()
            .clickable(
                onClick = {
                    onMessageClick(itemState.message)
                },
            )
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        val isDirectMessageChannel = itemState.message.channelInfo?.cid?.startsWith("!members") == true

        if (isDirectMessageChannel) {
            AmiAvatar(
                user = UserForAmiAvatar(
                    id = itemState.message.user.id,
                    name = itemState.message.user.name,
                    avatarUrl = itemState.message.user.image
                )
            )
        } else {
            AmiIconButton(
                size = 40.dp,
                color = CustomTheme.colorScheme.secondary,
                iconUrl = itemState.message.channelInfo?.image
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            // @TODO: show channel.otherUser.name instead of message.user.name
            val channelName = itemState.message.channelInfo?.name.takeIf { !it.isNullOrEmpty() } ?: itemState.message.user.name

            BasicText(
                text = channelName,
                style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )

            val foundMessagePreview = formatMessagePreview(
                    message = itemState.message,
                    showSenderName = true,
                    iconColor = CustomTheme.colorScheme.onSurfaceSoft,
                    isMine = itemState.message.user.id == currentUser?.id,
                    isDirectMessageChannel = isDirectMessageChannel
                )

            if (foundMessagePreview != null) {
                BasicText(
                    text = foundMessagePreview.annotatedString,
                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    inlineContent = foundMessagePreview.inlineContentMap
                )
            }
        }

        itemState.message.createdAt?.let {
            BasicText(
                text = formatRelative(
                    date = ZonedDateTime.ofInstant(
                        it.toInstant(),
                        ZoneId.systemDefault()
                    ),
                    locale = getLocale(),
                ),
                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
            )
        }
    }
}