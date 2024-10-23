package com.whoisup.app.stream

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.node.Ref
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.components.AmiAvatar
import com.whoisup.app.components.AmiBackButton
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.UserForAmiAvatar
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import java.time.ZoneId
import java.time.ZonedDateTime

@Composable
inline fun <T> AnimatedValueVisibility(
    value: T?,
    enter: EnterTransition = fadeIn() + expandVertically(clip = false),
    exit: ExitTransition = fadeOut() + shrinkVertically(clip = false),
    crossinline content: @Composable (T) -> Unit
) {
    val ref = remember {
        Ref<T>()
    }

    ref.value = value ?: ref.value

    AnimatedVisibility(
        visible = value != null,
        enter = enter,
        exit = exit,
        content = {
            ref.value?.let { value ->
                content(value)
            }
        }
    )
}

@Composable
fun AmiChannelHeader(
    listViewModel: MessageListViewModel,
    singleChannelViewModel: SingleChannelViewModel,
    onBackClick: () -> Unit,
) {
    val channel = listViewModel.channel
    val currentUser by listViewModel.user.collectAsState()

    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AmiBackButton(onBackClick = onBackClick)

            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                val otherUser = if (channel.isDirectMessageChannel()) {
                    channel.members.firstOrNull {
                        it.user.id != ChatClient.instance().getCurrentUser()?.id
                    }?.user
                } else {
                    null
                }

                if (otherUser != null) {
                    AmiAvatar(
                        user = UserForAmiAvatar(
                            id = otherUser.id,
                            name = otherUser.name,
                            avatarUrl = otherUser.image
                        ),
                        size = 50.dp
                    )
                }

                Column {
                    BasicText(
                        text = ChatTheme.channelNameFormatter.formatChannelName(
                            channel,
                            currentUser
                        ),
                        style = CustomTheme.typography.heading.copy(color = CustomTheme.colorScheme.onBackground)
                    )

                    if (otherUser != null) {
                        val context = LocalContext.current
                        val mood = otherUser.extraData["mood"] as? Map<*, *> ?: mapOf<String, Any>()
                        val translationKey = mood["translationKey"] as? String
                        val expiresAt = mood["expiresAt"] as? String

                        var moodTitle by rememberSaveable { mutableStateOf<String?>(null) }

                        LaunchedEffect(translationKey, expiresAt) {
                            val interestT9n = translationKey.takeIf { it?.isNotBlank() == true }?.let {
                                    ExtendedStreamPlugin.shared?.translate(
                                        "${it}.nameWouldLike",
                                        "interests"
                                    )
                                }

                            if (interestT9n != null) {
                                val isExpired = expiresAt != null && ZonedDateTime.parse(expiresAt).isBefore(ZonedDateTime.now(ZoneId.systemDefault()))

                                moodTitle = if (isExpired) {
                                    context.resources.getString(R.string.global_wasUpFor, interestT9n)
                                } else {
                                    context.resources.getString(R.string.global_isUpFor, interestT9n)
                                }
                            }
                        }

                        moodTitle?.let {
                            BasicText(
                                text = it,
                                style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onBackground)
                            )
                        }

                        AnimatedValueVisibility(value = listViewModel.typingUsers.takeIf { it.isNotEmpty() }) {
                            Row(
                                modifier = Modifier,
                                horizontalArrangement = Arrangement.spacedBy(6.dp),
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                val typingUsersText =
                                    LocalContext.current.resources.getQuantityString(
                                        io.getstream.chat.android.compose.R.plurals.stream_compose_message_list_header_typing_users,
                                        it.size,
                                        it.firstOrNull()?.name,
                                        (it.size - 1).coerceAtLeast(0),
                                    )

                                BasicText(
                                    text = "$typingUsersText...",
                                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onBackground),
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis,
                                )
                            }
                        }
                    }
                }
            }

            AmiIconButton(
                size = 40.dp,
                color = Color.Transparent,
                iconColor = CustomTheme.colorScheme.primary,
                iconId = R.drawable.more_horizontal,
                onClick = {
                    singleChannelViewModel.openModal(channel)
                }
            )
        }

        val otherUser = if (listViewModel.channel.isDirectMessageChannel()) {
            listViewModel.channel.members.firstOrNull {
                it.user.id != currentUser?.id
            }?.user
        } else {
            null
        }

        if (otherUser != null && !otherUser.isSupportTeamMember) {
            Divider()

            AmiInviteUser(otherUser = otherUser)
        }

        val mainHost = if (listViewModel.channel.isDirectMessageChannel()) {
            null
        } else {
            listViewModel.channel.createdBy
            // It would be nice if we could do something like the following.
            // But we don't have any guarantees that the main host will be present in the `channel.members` list
            // listViewModel.channel.members.firstOrNull {
            //     it.amiParticipantRole == AmiParticipantRole.Organizer
            // }
        }

        if (mainHost != null && mainHost.id != currentUser?.id) {
            Divider()

            AmiChatWithHost(mainHost = mainHost)
        }

        Divider()
    }
}

@Composable
private fun Divider() {
    Box(
        modifier = Modifier
            .height(1.dp)
            .fillMaxWidth()
            .background(CustomTheme.colorScheme.surfaceHard)
    )
}