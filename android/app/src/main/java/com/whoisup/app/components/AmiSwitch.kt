package com.whoisup.app.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.rememberSplineBasedDecay
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.AnchoredDraggableState
import androidx.compose.foundation.gestures.DraggableAnchors
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.anchoredDraggable
import androidx.compose.foundation.gestures.animateTo
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme
import kotlinx.coroutines.flow.collectLatest
import kotlin.math.roundToInt

internal val TrackWidth = 48.dp
internal val ThumbDiameter = TrackWidth / 1.75f

private val SwitchWidth = TrackWidth
private val SwitchHeight = ThumbDiameter
private val ThumbPathLength = TrackWidth - ThumbDiameter

private const val SwitchPositionalThreshold = 0.7f
private val SwitchVelocityThreshold = 125.dp

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AmiSwitch(checked: Boolean, onCheckedChange: (checked: Boolean) -> Unit) {
    val decayAnimationSpec = rememberSplineBasedDecay<Float>()

    /**
     * Begin shameless copy-paste from material Switch component:
     * https://android.googlesource.com/platform/frameworks/support/+/e6d33dd5d0a60001a5784d84123b05308d35f410/compose/material/material/src/commonMain/kotlin/androidx/compose/material/Switch.kt#103
     */
    val minBound = 0f
    val maxBound = with(LocalDensity.current) { ThumbPathLength.toPx() }
    // If we reach a bound and settle, we invoke onCheckedChange with the new value. If the user
    // does not update `checked`, we would now be in an invalid state. We keep track of the
    // the animation state through this, animating back to the previous value if we don't receive
    // a new checked value.
    var forceAnimationCheck by remember { mutableStateOf(false) }
    val switchVelocityThresholdPx = with(LocalDensity.current) { SwitchVelocityThreshold.toPx() }
    val anchoredDraggableState = remember(maxBound, switchVelocityThresholdPx) {
        AnchoredDraggableState(
            initialValue = checked,
            positionalThreshold = { distance -> distance * SwitchPositionalThreshold },
            velocityThreshold = { switchVelocityThresholdPx },
            snapAnimationSpec = tween(),
            decayAnimationSpec = decayAnimationSpec,
        )
            .apply {
                updateAnchors(
                    DraggableAnchors {
                        false at minBound
                        true at maxBound
                    }
                )
            }
    }
    val currentOnCheckedChange by rememberUpdatedState(onCheckedChange)
    val currentChecked by rememberUpdatedState(checked)
    LaunchedEffect(anchoredDraggableState) {
        snapshotFlow { anchoredDraggableState.currentValue }
            .collectLatest { newValue ->
                if (currentChecked != newValue) {
                    currentOnCheckedChange(newValue)
                    forceAnimationCheck = !forceAnimationCheck
                }
            }
    }
    LaunchedEffect(checked, forceAnimationCheck) {
        if (checked != anchoredDraggableState.currentValue) {
            anchoredDraggableState.animateTo(checked)
        }
    }
    /**
     * End shameless copy-paste from material Switch component
     */

    val interactionSource = remember { MutableInteractionSource() }
    val toggleableModifier = Modifier.toggleable(
        value = checked,
        onValueChange = onCheckedChange,
        enabled = true,
        role = Role.Switch,
        interactionSource = interactionSource,
        indication = null
    )

    val handleBackgroundColor: Color by animateColorAsState(
        when {
            // If we were to check for `draggableState.currentValue` here instead,
            // it would only change color after the drag animation finishes.
            checked -> CustomTheme.colorScheme.success
            else -> CustomTheme.colorScheme.surfaceHard
        },
        label = "handleBackgroundColor"
    )

    Box(
        modifier =
        Modifier
            .height(SwitchHeight)
            .width(SwitchWidth)
            .clip(CircleShape)
            .background(handleBackgroundColor)
            .then(toggleableModifier)
    ) {
        Box(
            Modifier
                // Offset the handle with the actual dragged (either animated or by user action)
                // distance.
                .offset { IntOffset(anchoredDraggableState.offset.roundToInt(), 0) }
                .anchoredDraggable(
                    state = anchoredDraggableState,
                    orientation = Orientation.Horizontal,
                    interactionSource = interactionSource,
                    startDragImmediately = false
                )
                .size(ThumbDiameter)
                .padding(2.dp)
                .clip(CircleShape)
                .background(CustomTheme.colorScheme.surface)
                .padding(2.dp)
                .clip(CircleShape)
                .background(CustomTheme.colorScheme.background)
        )
    }
}

@Preview(showBackground = true)
@Composable
fun AmiSwitchPreview() {
    CustomTheme {
        Column(
            modifier =
            Modifier
                .fillMaxSize()
                .background(CustomTheme.colorScheme.background)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            var value: Boolean by rememberSaveable { mutableStateOf(false) }

            BasicText(
                text = value.toString(),
                style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onSurface)
            )

            AmiSwitch(checked = value, onCheckedChange = { value = it })
        }
    }
}