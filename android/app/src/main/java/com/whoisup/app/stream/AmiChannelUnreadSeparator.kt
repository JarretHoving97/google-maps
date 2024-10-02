package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.ui.common.state.messages.list.UnreadSeparatorItemState

@Composable
fun AmiChannelUnreadSeparator(unreadSeparatorItemState: UnreadSeparatorItemState) {
    val text = if (unreadSeparatorItemState.unreadCount == 0) {
        stringResource(id = R.string.stream_compose_message_list_unread_separator_zero)
    } else {
        pluralStringResource(
            id = R.plurals.stream_compose_message_list_unread_separator,
            count = unreadSeparatorItemState.unreadCount,
            unreadSeparatorItemState.unreadCount
        )
    }

    Row(
        modifier = Modifier.fillMaxWidth().padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .height(0.5.dp)
                .weight(1f)
                .background(CustomTheme.colorScheme.primary)
        )
        BasicText(
            text = text,
            style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.primary)
        )
        Box(
            modifier = Modifier
                .height(0.5.dp)
                .weight(1f)
                .background(CustomTheme.colorScheme.primary)
        )
    }
}