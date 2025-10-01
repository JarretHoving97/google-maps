package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.DcIcon
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiChatCommunityAdminOnlyNotice(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(CustomTheme.colorScheme.surface)
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        DcIcon(
            id = R.drawable.alert_circle,
            contentDescription = null,
            size = 24.dp,
            color = CustomTheme.colorScheme.onSurface
        )

        BasicText(
            text = stringResource(R.string.AmiChatCommunityAdminOnlyNotice_body),
            style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface),
            modifier = Modifier.weight(1f)
        )
    }
}