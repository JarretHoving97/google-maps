package com.whoisup.app.components

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextDecoration
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.helpers.AnnotationTagUrl
import com.whoisup.app.helpers.INTERNAL_APP_HOSTS
import com.whoisup.app.helpers.customLinkify
import com.whoisup.app.helpers.customLinkifyWithMarkdown
import com.whoisup.app.helpers.hasAnyTag
import com.whoisup.app.helpers.urlAt
import java.net.URL

@Composable
fun AmiClickableText(
    text: String,
    textStyle: TextStyle,
    modifier: Modifier = Modifier,
    allowMarkdown: Boolean = false,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() },
    onClick: (() -> Unit)? = null,
    onLongPress: (() -> Unit)? = null,
) {
    val context = LocalContext.current

    val linkStyle = SpanStyle(textDecoration = TextDecoration.Underline)

    val linkifiedText = remember(text, allowMarkdown) {
        if (allowMarkdown) {
            text.customLinkifyWithMarkdown(linkStyle)
        } else {
            text.customLinkify(linkStyle)
        }
    }

    val hasAnyLink = remember(linkifiedText) {
        linkifiedText.hasAnyTag(AnnotationTagUrl)
    }

    if (hasAnyLink) {
        ClickableText(
            interactionSource = interactionSource,
            text = linkifiedText,
            modifier = modifier,
            style = textStyle,
            onLongPress = onLongPress,
            onClick = { position ->
                linkifiedText.urlAt(position) { urlString ->
                    // This should never fail in reality,
                    // because before adding it as an annotation,
                    // it will already be validated
                    val url = try {
                        URL(urlString)
                    } catch (e: Exception) {
                        // Invalid URL
                        null
                    }

                    if (url != null) {
                        if (INTERNAL_APP_HOSTS.contains(url.host)) {
                            val origin = url.protocol + "://" + url.authority
                            val fullPath = url.toString().replaceFirst(origin, "").takeIf { it.isNotBlank() } ?: "/"
                            ExtendedStreamPlugin.notifyNavigateToListeners(context, fullPath, true)
                        } else {
                            context.startActivity(
                                Intent(
                                    Intent.ACTION_VIEW,
                                    Uri.parse(url.toString()),
                                ),
                            )
                        }
                    } else {
                        onClick?.invoke()
                    }
                } ?: onClick?.invoke()
            },
        )
    } else {
        BasicText(
            text = linkifiedText,
            modifier = modifier,
            style = textStyle,
        )
    }
}