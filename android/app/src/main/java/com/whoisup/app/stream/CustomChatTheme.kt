package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.ui.theme.StreamColors

@Composable
fun CustomChatTheme(content: @Composable () -> Unit) {
    ChatTheme(
        reactionIconFactory = AmiReactionIconFactory(),
        attachmentsPickerTabFactories = attachmentsPickerTabFactories(),
        colors = StreamColors.defaultColors().copy(
            primaryAccent = CustomTheme.colorScheme.primary
        ),
    ) {
        content()
    }
}