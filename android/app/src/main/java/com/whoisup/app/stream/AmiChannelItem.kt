package com.whoisup.app.stream

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import coil.decode.SvgDecoder
import coil.request.ImageRequest
import com.whoisup.app.R
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.DcIcon
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.modifiers.layoutPadding
import com.whoisup.app.stream.extensions.ChatChannelRelatedConceptType
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.relatedConceptType
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.formatRelative
import com.whoisup.app.utils.getLocale
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.client.extensions.currentUserUnreadCount
import io.getstream.chat.android.compose.state.channels.list.ItemState
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.ui.util.getLastMessage
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.User
import java.time.ZoneId
import java.time.ZonedDateTime

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AmiChannelItem(
    itemState: ItemState.ChannelItemState,
    singleChannelViewModel: SingleChannelViewModel,
    currentUser: User?,
    onChannelClick: (Channel) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight()
            .combinedClickable(
                onClick = { onChannelClick(itemState.channel) },
                onLongClick = remember(singleChannelViewModel) {
                    {
                        singleChannelViewModel.openModal(itemState.channel)
                    }
                },
                indication = rememberRipple(),
                interactionSource = remember { MutableInteractionSource() },
            )
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (itemState.channel.isDirectMessageChannel()) {
            val otherUser = itemState.channel.members.firstOrNull {
                it.user.id != ChatClient.instance().getCurrentUser()?.id
            }?.user

            AmiAvatar(user = UserForAmiAvatar(
                id = otherUser?.id,
                name = otherUser?.name,
                avatarUrl = otherUser?.image
            ))
        } else if (itemState.channel.relatedConceptType is ChatChannelRelatedConceptType.Activity) {
            AmiIconButton(
                size = 40.dp,
                color = CustomTheme.colorScheme.secondary,
                iconUrl = itemState.channel.image
            )
        } else {
            Box {
                AsyncImage(
                    model = ImageRequest.Builder(LocalContext.current)
                        .data(itemState.channel.image)
                        .decoderFactory(SvgDecoder.Factory())
                        .build(),
                    contentDescription = null,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(CustomTheme.colorScheme.surface),
                    contentScale = ContentScale.Crop,
                )

                if (itemState.channel.relatedConceptType is ChatChannelRelatedConceptType.Community) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .layoutPadding(horizontal = (-2).dp, vertical = (-2).dp)
                    ) {
                        AmiIconButton(
                            size = 16.dp,
                            color = CustomTheme.colorScheme.surface,
                            iconId = R.drawable.community,
                            iconScale = 0.5f
                        )
                    }
                }
            }
        }

        Column(modifier = Modifier.weight(1f)) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                val channelName = ChatTheme.channelNameFormatter.formatChannelName(itemState.channel, currentUser)

                BasicText(
                    text = channelName,
                    modifier = Modifier.weight(1f, false),
                    style = CustomTheme.typography.paragraph.copy(
                        color = CustomTheme.colorScheme.onBackground,
                        fontWeight = if (itemState.channel.currentUserUnreadCount > 0) {
                            FontWeight.W500
                        } else {
                            FontWeight.W400
                        }
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )

                if (itemState.isMuted) {
                    DcIcon(
                        id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_mute,
                        contentDescription = null,
                        size = 12.dp,
                        color = CustomTheme.colorScheme.onBackground
                    )
                }
            }

            if (itemState.typingUsers.isNotEmpty()) {
                AmiTypingUsers(itemState.typingUsers)
            } else {
                val lastMessagePreview =
                    itemState.channel.getLastMessage(currentUser)?.let { lastMessage ->
                        formatMessagePreview(
                            message = lastMessage,
                            showSenderName = true,
                            isMine = lastMessage.user.id == currentUser?.id,
                            isDirectMessageChannel = itemState.channel.isDirectMessageChannel()
                        )
                    }

                if (lastMessagePreview != null) {
                    BasicText(
                        text = lastMessagePreview.annotatedString,
                        style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        inlineContent = lastMessagePreview.inlineContentMap
                    )
                }
            }
        }

        itemState.channel.lastUpdated?.let {
            BasicText(
                text = formatRelative(
                    date = ZonedDateTime.ofInstant(
                        it.toInstant(),
                        ZoneId.systemDefault()
                    ),
                    locale = getLocale()
                ),
                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
            )
        }

        if (itemState.channel.currentUserUnreadCount > 0) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .defaultMinSize(minWidth = 16.dp, minHeight = 16.dp)
                    .background(CustomTheme.colorScheme.secondary)
                    .padding(horizontal = 4.dp),
                contentAlignment = Alignment.Center
            ) {
                BasicText(
                    text = if (itemState.channel.currentUserUnreadCount > 99) {
                        "99+"
                    } else {
                        itemState.channel.currentUserUnreadCount.toString()
                    },
                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSecondary),
                )
            }
        }
    }
}