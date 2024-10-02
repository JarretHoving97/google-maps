package com.whoisup.app.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.ui.theme.CustomTheme

enum class TextColor {
    Danger
}

enum class IconColor {
    Primary
}

enum class IconSize {
    Small,
    Medium
}

enum class BackgroundTheme {
    MatchBackground,
    MatchSurface
}

@Composable
fun AmiButtonLabel(
    title: String,
    @DrawableRes iconId: Int = R.drawable.angle_right,
    textColor: TextColor? = null,
    iconColor: IconColor? = null,
    iconSize: IconSize = IconSize.Small,
    backgroundTheme: BackgroundTheme = BackgroundTheme.MatchSurface,
    @DrawableRes leftIconId: Int? = null,
    belowTitleContent: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null
) {
    val finalTextColor =
        if (textColor == TextColor.Danger) {
            CustomTheme.colorScheme.danger
        } else if (backgroundTheme == BackgroundTheme.MatchBackground) {
            CustomTheme.colorScheme.onBackground
        } else {
            CustomTheme.colorScheme.onSurface
        }

    val finalIconColor =
        if (iconColor == IconColor.Primary) {
            CustomTheme.colorScheme.primary
        } else {
            finalTextColor
        }

    Row(
        modifier =
        Modifier.clip(RoundedCornerShape(12.dp))
            .then(if (onClick != null) {
                Modifier.clickable(
                    onClick = {
                        onClick()
                    }
                )
            } else {
                Modifier
            })
            .background(
                if (backgroundTheme == BackgroundTheme.MatchBackground) {
                    CustomTheme.colorScheme.background
                } else {
                    CustomTheme.colorScheme.surface
                }
            )
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (leftIconId != null) {
            DcIcon(
                id = leftIconId,
                contentDescription = null,
                size = 20.dp,
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            BasicText(
                text = title,
                style =
                CustomTheme.typography.subhead.copy(
                    color = finalTextColor,
                )
            )

            if (belowTitleContent != null) {
                belowTitleContent()
            }
        }

        DcIcon(
            id = iconId,
            contentDescription = null,
            size =
            if (iconSize == IconSize.Small) {
                12.dp
            } else {
                16.dp
            },
            color = finalIconColor
        )
    }
}