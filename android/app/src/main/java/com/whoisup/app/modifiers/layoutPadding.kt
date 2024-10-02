package com.whoisup.app.modifiers

import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.layout
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.offset

// Jetpack Compose doesn't have negative margin or padding.
// So we'll use this custom modifier instead.
// Taken from:
// https://www.reddit.com/r/androiddev/comments/14f7fax/negative_padding_for_jetpack_compose_made_possible/
fun Modifier.layoutPadding(horizontal: Dp = 0.dp, vertical: Dp = 0.dp) = layout { measurable, constraints ->
    val placeable =
        // Step 1
        measurable.measure(constraints.offset((-horizontal * 2).roundToPx()))
    layout(
        // Step 2
        placeable.width + (horizontal * 2).roundToPx(),
        placeable.height + (vertical * 2).roundToPx(),

        // Step 3
    ) {
        placeable.place(0 + horizontal.roundToPx(), 0 + vertical.roundToPx())
    }
}