package com.whoisup.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiHeader(title: String? = null, onBackClick: () -> Unit) {
    Column(
        modifier = Modifier
            .zIndex(10f)
            .background(CustomTheme.colorScheme.background)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AmiBackButton(onBackClick = onBackClick)

            if (title != null) {
                BasicText(
                    text = title,
                    style = CustomTheme.typography.heading.copy(color = CustomTheme.colorScheme.onBackground)
                )
            }

            Spacer(modifier = Modifier.width(40.dp))
        }

        Box(
            modifier = Modifier
                .height(2.dp)
                .fillMaxWidth()
                .background(CustomTheme.colorScheme.surfaceHard)
        )
    }
}