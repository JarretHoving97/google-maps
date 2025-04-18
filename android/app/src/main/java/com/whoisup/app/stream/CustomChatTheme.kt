package com.whoisup.app.stream

import androidx.compose.material.LocalContentColor
import androidx.compose.material.ripple.RippleAlpha
import androidx.compose.material.ripple.RippleTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.ui.theme.StreamColors

@Immutable
private object CustomStreamRippleTheme : RippleTheme {
    @Composable
    override fun defaultColor(): Color {
        return RippleTheme.defaultRippleColor(
            contentColor = LocalContentColor.current,
            lightTheme = true
        )
    }

    @Composable
    override fun rippleAlpha(): RippleAlpha {
        return RippleTheme.defaultRippleAlpha(
            contentColor = LocalContentColor.current,
            lightTheme = true
        )
    }
}

@Composable
fun CustomChatTheme(content: @Composable () -> Unit) {
    ChatTheme(
        reactionIconFactory = AmiReactionIconFactory(),
        attachmentsPickerTabFactories = attachmentsPickerTabFactories(),
        colors = StreamColors.defaultColors().copy(
            primaryAccent = CustomTheme.colorScheme.primary
        ),
        rippleTheme = CustomStreamRippleTheme,
    ) {
        content()
    }
}