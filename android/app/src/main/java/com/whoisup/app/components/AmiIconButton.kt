package com.whoisup.app.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.times
import coil.compose.AsyncImage
import coil.decode.SvgDecoder
import coil.request.ImageRequest

@Composable
fun AmiIconButton(
    size: Dp,
    color: Color,
    @DrawableRes iconId: Int? = null,
    iconColor: Color? = null,
    iconUrl: String? = null,
    filled: Boolean = true,
    onClick: (() -> Unit)? = null
) {
    Box(
        modifier =
        Modifier
            .size(size)
            .clip(CircleShape)
            .then(
                if (onClick != null) {
                    Modifier.clickable { onClick() }
                } else {
                    Modifier
                }
            )
            .border(2.dp, color, CircleShape)
            .then(
                if (filled) {
                    Modifier.background(color)
                } else {
                    Modifier
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        if (iconUrl != null) {
            AsyncImage(
                modifier = Modifier.size(0.4 * size).aspectRatio(1f),
                model =
                ImageRequest.Builder(LocalContext.current)
                    .data(iconUrl)
                    .decoderFactory(SvgDecoder.Factory())
                    .build(),
                contentDescription = null,
                contentScale = androidx.compose.ui.layout.ContentScale.Fit,
            )
        } else if (iconId != null) {
            DcIcon(
                id = iconId,
                contentDescription = null,
                size = 0.4 * size,
                color = iconColor,
            )
        }
    }
}
