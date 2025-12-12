package com.whoisup.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiPinnedMessage(
    text: String?,
    isAllowedToUpdatePinnedMessage: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .then(
                if (isAllowedToUpdatePinnedMessage) {
                    Modifier.clickable(
                        interactionSource = interactionSource,
                        indication = ripple(),
                        onClick = onClick
                    )
                } else {
                    Modifier
                }
            )
            .background(CustomTheme.colorScheme.secondary)
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            DcIcon(
                id = R.drawable.pinvol,
                contentDescription = null,
                size = 12.dp,
                color = CustomTheme.colorScheme.onSecondary
            )

            BasicText(
                text = stringResource(id = R.string.AmiPinnedMessage_final_title),
                style = CustomTheme.typography.caption.copy(color = CustomTheme.colorScheme.onSecondary)
            )
        }

        val placeholder = stringResource(id = R.string.AmiPinnedMessage_final_placeholder)

        val textOrPlaceholder = remember(text) {
            if (text.isNullOrEmpty()) {
                placeholder
            } else {
                text
            }
        }

        val textStyle = CustomTheme.typography.paragraph.copy(color = if (text.isNullOrEmpty()) {
                CustomTheme.colorScheme.onSecondary.copy(alpha = 0.8f)
            } else {
                CustomTheme.colorScheme.onSecondary
            }
        )

        AmiClickableText(
            text = textOrPlaceholder,
            textStyle = textStyle,
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 64.dp)
                .verticalScroll(rememberScrollState()),
            interactionSource = interactionSource,
            onClick = if (isAllowedToUpdatePinnedMessage) {
                onClick
            } else {
                null
            }
        )
    }
}