package com.whoisup.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiHeader(onBackClick: () -> Unit) {
    Column(
        modifier = Modifier
            .zIndex(10f)
            .background(CustomTheme.colorScheme.background)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            // horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AmiBackButton(onBackClick = onBackClick)
        }

        Box(
            modifier = Modifier
                .height(2.dp)
                .fillMaxWidth()
                .background(CustomTheme.colorScheme.surfaceHard)
        )
    }
}