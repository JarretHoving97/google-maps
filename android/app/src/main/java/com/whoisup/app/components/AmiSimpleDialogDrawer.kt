package com.whoisup.app.components

import android.view.Gravity
import android.view.Window
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.window.DialogWindowProvider
import com.whoisup.app.ui.theme.CustomTheme

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun AmiSimpleDialogDrawer(
    showDialog: Boolean,
    onDismissRequest: () -> Unit,
    content: @Composable BoxScope.() -> Unit
) {

    var showAnimatedDialog by remember { mutableStateOf(false) }

    LaunchedEffect(showDialog) {
        if (showDialog) showAnimatedDialog = true
    }

    if (showAnimatedDialog) {
        Dialog(
            onDismissRequest = onDismissRequest,
            properties = DialogProperties(
                usePlatformDefaultWidth = false
            )
        ) {
            val dialogWindow = getDialogWindow()

            SideEffect {
                dialogWindow.let { window ->
                    window?.setDimAmount(0f)
                    window?.setWindowAnimations(-1)
                    window?.setGravity(Gravity.BOTTOM)
                }
            }

            Box(modifier = Modifier.fillMaxSize()) {
                var animateIn by remember { mutableStateOf(false) }
                LaunchedEffect(Unit) { animateIn = true }

                AnimatedVisibility(
                    visible = animateIn && showDialog,
                    enter = fadeIn(),
                    exit = fadeOut(),
                ) {
                    Box(
                        Modifier
                            // Trigger a `dismissRequest` when clicking the scrim
                            .pointerInput(Unit) { detectTapGestures { onDismissRequest() } }
                            .fillMaxSize()
                            .background(CustomTheme.colorScheme.overlay)
                    ) {
                        Box(
                            Modifier
                                .fillMaxSize()
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
                        ) {
                            content()
                        }

                        DisposableEffect(Unit) {
                            onDispose {
                                showAnimatedDialog = false
                            }
                        }
                    }
                }
            }
        }
    }
}

@ReadOnlyComposable
@Composable
fun getDialogWindow(): Window? = (LocalView.current.parent as? DialogWindowProvider)?.window