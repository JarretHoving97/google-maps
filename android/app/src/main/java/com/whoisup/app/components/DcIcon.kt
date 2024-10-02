package com.whoisup.app.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp

enum class ContentScale {
    FillHeight,
    FillWidth,
    Fit
}

@Composable
fun DcIcon(
    @DrawableRes id: Int,
    contentDescription: String?,
    size: Dp,
    modifier: Modifier = Modifier,
    color: Color? = null,
    contentScale: ContentScale = ContentScale.Fit
) {
    val width =
        if (contentScale != ContentScale.FillHeight) {
            size
        } else {
            Dp.Unspecified
        }

    val height =
        if (contentScale != ContentScale.FillWidth) {
            size
        } else {
            Dp.Unspecified
        }

    Image(
        painter = painterResource(id),
        contentDescription = contentDescription,
        modifier = modifier.size(width = width, height = height),
        colorFilter =
        if (color != null) {
            ColorFilter.tint(color)
        } else {
            null
        }
    )
}