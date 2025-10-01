package com.whoisup.app.stream

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiChannelCreateActivity(communityId: String) {
    val context = LocalContext.current

    Row(
        modifier = Modifier
            .clickable(onClick = {
                val route = "/upsert-activity?communityId=${communityId}"
                ExtendedStreamPlugin.notifyNavigateToListeners(context, route, true)
            })
            .fillMaxWidth()
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically
    ) {
        BasicText(
            text = stringResource(R.string.global_activity_create),
            style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground)
        )

        AmiIconButton(
            size = 24.dp,
            color = CustomTheme.colorScheme.primary,
            iconId = R.drawable.plus,
            iconColor = CustomTheme.colorScheme.onPrimary
        )
    }
}