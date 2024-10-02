package com.whoisup.app.components

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.indication
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow

/**
 * A spin-off of a Foundation component that allows calling long press handlers.
 * Contains only one additional parameter.
 *
 * @param onLongPress Handler called on long press.
 *
 * @see androidx.compose.foundation.text.ClickableText
 */
@Composable
fun ClickableText(
    interactionSource: MutableInteractionSource,
    text: AnnotatedString,
    modifier: Modifier = Modifier,
    style: TextStyle = TextStyle.Default,
    softWrap: Boolean = true,
    overflow: TextOverflow = TextOverflow.Clip,
    maxLines: Int = Int.MAX_VALUE,
    onTextLayout: (TextLayoutResult) -> Unit = {},
    onLongPress: (() -> Unit)? = null,
    onClick: (Int) -> Unit,
) {
    val layoutResult = remember { mutableStateOf<TextLayoutResult?>(null) }
    val pressIndicator = Modifier
        .indication(interactionSource, null)
        .pointerInput(Unit) {
            detectTapGestures(
                onLongPress = {
                    onLongPress?.invoke()
                },
                onPress = { offset ->
                    val press = PressInteraction.Press(offset)
                    interactionSource.emit(press)

                    tryAwaitRelease()

                    interactionSource.emit(PressInteraction.Release(press))
                },
                onTap = { pos ->
                    layoutResult.value?.let { layoutResult ->
                        onClick(layoutResult.getOffsetForPosition(pos))
                    }
                },
            )
        }

    BasicText(
        text = text,
        modifier = modifier.then(pressIndicator),
        style = style,
        softWrap = softWrap,
        overflow = overflow,
        maxLines = maxLines,
        onTextLayout = {
            layoutResult.value = it
            onTextLayout(it)
        },
    )
}