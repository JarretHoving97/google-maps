package com.whoisup.app.ui.theme

import androidx.compose.foundation.LocalIndication
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf

// https://www.droidcon.com/2022/01/26/building-design-system-with-jetpack-compose/
// https://developer.android.com/jetpack/compose/designsystems/custom#implementing-fully-custom

val LocalCustomColorScheme = staticCompositionLocalOf { DarkColorScheme }
val LocalCustomTypography = staticCompositionLocalOf { CustomTypography() }

@Composable
fun CustomTheme(darkTheme: Boolean = false, content: @Composable () -> Unit) {
  val customColorScheme =
    when {
      darkTheme -> DarkColorScheme
      else -> LightColorScheme
    }
  val rippleIndication = rememberRipple()
  val customTypography = CustomTypography()
  CompositionLocalProvider(
    LocalCustomColorScheme provides customColorScheme,
    LocalIndication provides rippleIndication,
    LocalCustomTypography provides customTypography,
    content = content
  )
}

object CustomTheme {
  val colorScheme: CustomColorScheme
    @Composable @ReadOnlyComposable get() = LocalCustomColorScheme.current

  val typography: CustomTypography
    @Composable @ReadOnlyComposable get() = LocalCustomTypography.current
}