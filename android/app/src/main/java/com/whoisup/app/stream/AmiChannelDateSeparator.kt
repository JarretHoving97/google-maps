package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.formatRelative
import com.whoisup.app.utils.getLocale
import io.getstream.chat.android.ui.common.state.messages.list.DateSeparatorItemState
import java.time.ZoneId
import java.time.ZonedDateTime

@Composable
fun AmiChannelDateSeparator(dateSeparator: DateSeparatorItemState) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 16.dp),
        contentAlignment = Alignment.Center
    ) {
        BasicText(
            text = formatRelative(
                date = ZonedDateTime.ofInstant(dateSeparator.date.toInstant(), ZoneId.systemDefault()),
                locale = getLocale(),
                ifTodayHideHours = true
            ),
            modifier = Modifier
                .clip(CircleShape)
                .background(CustomTheme.colorScheme.surface)
                .padding(horizontal = 12.dp, vertical = 4.dp),
            style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurfaceSoft)
        )
    }
}