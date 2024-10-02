package com.whoisup.app.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun BoxScope.AmiEmptyContent(
    text: String,
    @DrawableRes iconId: Int,
) {
    Column(
        modifier = Modifier
            .align(Alignment.Center)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(
            painter = painterResource(id = iconId),
            contentDescription = null,
            modifier = Modifier.size(48.dp),
            tint = CustomTheme.colorScheme.onSurfaceSoft,
        )

        BasicText(
            text = text,
            style = CustomTheme.typography.subhead.copy(
                color = CustomTheme.colorScheme.onSurfaceSoft,
                textAlign = TextAlign.Center
            ),
        )
    }
}