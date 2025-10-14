package com.whoisup.app.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme

enum class BorderTheme {
    OnBackground,
    OnPrimary
}

@Composable
fun AmiRadioButtonIcon(
    checked: Boolean?,
    modifier: Modifier = Modifier,
    disabled: Boolean = false,
    borderTheme: BorderTheme = BorderTheme.OnBackground
) {
    val alpha by
    animateFloatAsState(
        targetValue =
        if (disabled) {
            0.2f
        } else {
            1f
        },
        label = "checkboxAlpha"
    )

    val borderWidth by
    animateDpAsState(
        if (checked == true) {
            8.dp
        } else {
            2.dp
        },
        label = "radioButtonIconBorderColor"
    )

    val borderColor by
    animateColorAsState(
        if (checked == true) {
            if (borderTheme == BorderTheme.OnPrimary) {
                CustomTheme.colorScheme.onPrimary
            } else {
                CustomTheme.colorScheme.primary
            }
        } else {
            if (borderTheme == BorderTheme.OnPrimary) {
                CustomTheme.colorScheme.onPrimary.copy(alpha = 0.2f)
            } else {
                CustomTheme.colorScheme.onBackground.copy(alpha = 0.1f)
            }
        },
        label = "radioButtonIconBorderColor"
    )

    Box(
        modifier = Modifier
            .alpha(alpha)
            .size(24.dp)
            .clip(CircleShape)
            .then(modifier)
            .border(borderWidth, borderColor, CircleShape)
            .background(Color.Transparent),
    )
}

@Preview(showBackground = true)
@Composable
fun AmiCheckboxIconPreview() {
    Row {
        CustomTheme(darkTheme = false) {
            Column(
                modifier = Modifier.background(CustomTheme.colorScheme.background),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                AmiRadioButtonIcon(checked = false)
                AmiRadioButtonIcon(checked = true)
                AmiRadioButtonIcon(checked = false, disabled = true)
                AmiRadioButtonIcon(checked = true, disabled = true)
            }
        }
        CustomTheme(darkTheme = true) {
            Column(
                modifier = Modifier.background(CustomTheme.colorScheme.background),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                AmiRadioButtonIcon(checked = false)
                AmiRadioButtonIcon(checked = true)
                AmiRadioButtonIcon(checked = false, disabled = true)
                AmiRadioButtonIcon(checked = true, disabled = true)
            }
        }
    }
}
