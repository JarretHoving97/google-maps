package com.whoisup.app.components

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiBackButton(onBackClick: () -> Unit) {
    // @TODO: mirrorRtl
    AmiIconButton(
        size = 40.dp,
        color = Color.Transparent,
        iconColor = CustomTheme.colorScheme.primary,
        iconId = R.drawable.arrow_left,
        onClick = onBackClick
    )
}