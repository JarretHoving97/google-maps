package com.whoisup.app.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme

enum class AmiButtonSize(val scale: Float) {
    Small(0.8f),
    Medium(1.0f),
}

data class AmiButtonTheme(
    val color: Color,
    val textColor: Color,
    val filled: Boolean = true,
)

@Composable
fun AmiButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: AmiButtonSize = AmiButtonSize.Medium,
    theme: AmiButtonTheme = AmiButtonTheme(
        color = CustomTheme.colorScheme.primary,
        textColor = CustomTheme.colorScheme.onPrimary,
    ),
    enabled: Boolean = true,
    loading: Boolean = false
) {
    // @TODO: add loading icon or something similar for loading state
    val alpha by animateFloatAsState(
        if (!enabled || loading) {
            0.5f
        } else {
            1f
        }, label = "buttonAlpha"
    )

    BasicText(
        text = text,
        modifier = modifier
            .alpha(alpha)
            .clip(CircleShape)
            .clickable(onClick = {
                if (enabled && !loading) {
                    onClick()
                }
            })
            .border(2.dp, theme.color, CircleShape)
            .clip(CircleShape)
            .background(
                if (theme.filled) {
                    theme.color
                } else {
                    Color.Unspecified
                }
            )
            .padding(horizontal = (24 * size.scale).dp, vertical = (12 * size.scale).dp),
        style = CustomTheme.typography.subhead.copy(
            color = theme.textColor,
            fontSize = CustomTheme.typography.subhead.fontSize * size.scale,
            textAlign = TextAlign.Center
        )
    )
}
