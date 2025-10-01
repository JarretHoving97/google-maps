package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiButtonSize
import com.whoisup.app.components.AmiButtonTheme
import com.whoisup.app.helpers.INTERNAL_APP_HOSTS
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.Message
import java.net.URL

@Composable
fun AmiMessageActionButton(
    message: Message,
    modifier: Modifier = Modifier,
    theme: AmiButtonTheme = AmiButtonTheme(
        color = CustomTheme.colorScheme.primary,
        textColor = CustomTheme.colorScheme.onPrimary,
    ),
) {
    val context = LocalContext.current

    val actionUrl = message.extraData["actionUrl"] as? String

    val path = remember(actionUrl) {
        val url = try {
            URL(actionUrl)
        } catch (e: Exception) {
            // Invalid URL
            null
        }

        if (url != null) {
            if (INTERNAL_APP_HOSTS.contains(url.host)) {
                val origin = url.protocol + "://" + url.authority
                return@remember url.toString().replaceFirst(origin, "").takeIf { it.isNotBlank() } ?: "/"
            }
        }

        return@remember null
    }

    val textResourceId = remember(path) {
        if (path != null) {
            if (path.startsWith("/upsert-activity")) {
                if (path.lowercase().contains("clonedActivityId".lowercase())) {
                    return@remember R.string.global_activity_repeat
                }
                return@remember R.string.global_activity_create
            }

            if (path.startsWith("/activity-immersive")) {
                return@remember R.string.global_activity_view
            }
        }

        return@remember R.string.global_view
    }

    if (path != null) {
        AmiButton(
            text = stringResource(id = textResourceId),
            onClick = {
                ExtendedStreamPlugin.notifyNavigateToListeners(context, path, true)
            },
            modifier = modifier,
            size = AmiButtonSize.Small,
            theme = theme
        )
    }
}