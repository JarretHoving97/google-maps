package com.whoisup.app.stream

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.R
import io.getstream.chat.android.models.User

@Composable
fun AmiTypingUsers(typingUsers: List<User>) {
    AnimatedValueVisibility(value = typingUsers.takeIf { it.isNotEmpty() }) {
        Row(
            modifier = Modifier,
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            val typingUsersText =
                LocalContext.current.resources.getQuantityString(
                    R.plurals.stream_compose_message_list_header_typing_users,
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