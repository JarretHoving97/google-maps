package com.whoisup.app.components

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.whoisup.app.ui.theme.CustomTheme

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun AmiSimpleMenu(
    visible: Boolean,
    onDismiss: () -> Unit = {},
    content: @Composable () -> Unit,
) {
    AnimatedVisibility(
        visible = visible,
        enter = fadeIn(),
        exit = fadeOut(animationSpec = tween()),
    ) {
        Box(
            modifier = Modifier
                .background(CustomTheme.colorScheme.overlay)
                .fillMaxSize()
                .clickable(
                    onClick = onDismiss,
                    indication = null,
                    interactionSource = remember { MutableInteractionSource() },
                ),
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .animateEnterExit(
                        enter = slideInVertically(
                            initialOffsetY = { height -> height },
                            animationSpec = tween(),
                        ),
                        exit = slideOutVertically(
                            targetOffsetY = { height -> height },
                            animationSpec = tween(),
                        ),
                    )
                    .clickable(
                        onClick = {},
                        indication = null,
                        interactionSource = remember { MutableInteractionSource() },
                    )
            ) {
                content()
            }
        }

        BackHandler(enabled = true, onBack = onDismiss)
    }
}
