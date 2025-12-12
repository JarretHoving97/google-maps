package com.whoisup.app.ui.theme

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.compose.foundation.LocalIndication
import androidx.compose.material.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.staticCompositionLocalOf
import com.whoisup.app.stream.AmiAttachmentFactory
import com.whoisup.app.stream.CustomChatTheme
import com.whoisup.app.stream.MediaGalleryPreviewContract
import com.whoisup.app.stream.attachmentFactories

// https://www.droidcon.com/2022/01/26/building-design-system-with-jetpack-compose/
// https://developer.android.com/jetpack/compose/designsystems/custom#implementing-fully-custom

val LocalCustomColorScheme = staticCompositionLocalOf { DarkColorScheme }
val LocalCustomTypography = staticCompositionLocalOf { CustomTypography() }
val LocalCustomAttachmentFactories = compositionLocalOf<List<AmiAttachmentFactory>> {
  error("No attachment factories provided! Make sure to wrap all usages of Stream components in a ChatTheme.")
}

@Composable
fun CustomTheme(darkTheme: Boolean = false, content: @Composable () -> Unit) {
  val mediaGalleryPreviewLauncher = rememberLauncherForActivityResult(
    contract = MediaGalleryPreviewContract(),
    onResult = {
      // If we ever want to implement "show in chat" or actions like that,
      // we can use this callback for that.
    },
  )

  val customColorScheme =
    when {
      darkTheme -> DarkColorScheme
      else -> LightColorScheme
    }
  val rippleIndication = ripple()
  val customTypography = CustomTypography()
  val customAttachmentFactories = attachmentFactories(mediaGalleryPreviewLauncher)

  CompositionLocalProvider(
    LocalCustomColorScheme provides customColorScheme,
    LocalIndication provides rippleIndication,
    LocalCustomTypography provides customTypography,
    LocalCustomAttachmentFactories provides customAttachmentFactories,
    content = {
      CustomChatTheme {
        content()
      }
    }
  )
}

object CustomTheme {
  val colorScheme: CustomColorScheme
    @Composable @ReadOnlyComposable get() = LocalCustomColorScheme.current

  val typography: CustomTypography
    @Composable @ReadOnlyComposable get() = LocalCustomTypography.current

  val attachmentFactories: List<AmiAttachmentFactory>
    @Composable @ReadOnlyComposable get() = LocalCustomAttachmentFactories.current
}