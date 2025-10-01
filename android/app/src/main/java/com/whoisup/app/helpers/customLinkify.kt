package com.whoisup.app.helpers

import android.annotation.SuppressLint
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.text.ClickableText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.util.fastAny
import androidx.core.util.PatternsCompat
import com.whoisup.app.ui.theme.CustomTheme
import java.net.URL
import java.util.regex.Pattern

const val AnnotationTagUrl: String = "URL"

val INTERNAL_APP_HOSTS = listOf(
    "qa.app.amigosapp.nl",
    "app.amigosapp.nl",
    "app.amigossocial.com",
)

val INTERNAL_SITE_HOSTS = listOf(
    "amigosapp.nl",
    "amigossocial.com",
)

private fun parseUrlStringSafe(urlString: String?, validateInternalHost: Boolean = false): URL? {
    if (urlString.isNullOrBlank()) {
        return null
    }

    try {
        // Plain URL
        val url = URL(if (urlString.startsWith("https")) {
            urlString
        } else if (urlString.startsWith("http")) {
            urlString.replaceFirst("http", "https")
        } else {
            "https://$urlString"
        })

        if (validateInternalHost) {
            if (!INTERNAL_APP_HOSTS.contains(url.host) && !INTERNAL_SITE_HOSTS.contains(url.host)) {
                return null
            }
        }

        return url
    } catch (e: Exception) {
        // Invalid URL
        return null
    }
}

@SuppressLint("RestrictedApi")
private val urlPattern: Pattern = PatternsCompat.AUTOLINK_WEB_URL

fun AnnotatedString.Builder.linkify(text: String, linkStyle: SpanStyle) {
    // Regular expression to match plain URLs
    val regex = Pattern.compile("(${urlPattern})")
    val matcher = regex.matcher(text)

    var lastEndIndex = 0

    while (matcher.find()) {
        val startIndex = matcher.start()
        val endIndex = matcher.end()
        val fullMatch: String? = matcher.group(0)
        val plainUrl: String? = matcher.group(1)

        // Append text before the match
        append(text.substring(lastEndIndex, startIndex))

        val urlObj = parseUrlStringSafe(plainUrl)

        when {
            urlObj != null -> {
                // Plain URL
                pushStringAnnotation(tag = AnnotationTagUrl, annotation = urlObj.toString())
                withStyle(style = linkStyle) {
                    append(plainUrl)
                }
                pop()
            }
            fullMatch != null -> {
                // url was invalid, and no (valid) markdown was found
                // just show the full matched text
                append(fullMatch)
            }
        }

        lastEndIndex = endIndex
    }

    // Append any remaining text after the last match
    if (lastEndIndex < text.length) {
        append(text.substring(lastEndIndex))
    }
}

fun String.customLinkify(
    linkStyle: SpanStyle
): AnnotatedString = buildAnnotatedString {
    this.linkify(text = this@customLinkify, linkStyle = linkStyle)
}

fun String.customLinkifyWithMarkdown(
    linkStyle: SpanStyle,
    addAnnotations: Boolean = true
): AnnotatedString = buildAnnotatedString {
    // Regular expression to match Markdown-style links and plain URLs
    // It's not working unfortunately (it only matches the first or)
    // val pattern = "\\[([\\p{L}\\w\\-:/. ]+)]\\((${urlPattern})\\)|(${urlPattern})"

    // Regular expression to match Markdown-style links
    val pattern = "\\[([\\p{L}\\w\\-:/. ]+)]\\((${urlPattern})\\)"

    val regex = Pattern.compile(pattern)
    val matcher = regex.matcher(this@customLinkifyWithMarkdown)

    var lastEndIndex = 0

    while (matcher.find()) {
        val startIndex = matcher.start()
        val endIndex = matcher.end()
        val fullMatch: String? = matcher.group(0)
        val linkText: String? = matcher.group(1)
        val url: String? = matcher.group(2)

        val beforeText = this@customLinkifyWithMarkdown.substring(lastEndIndex, startIndex)

        // Append text before the match
        if (addAnnotations) {
            this.linkify(text = beforeText, linkStyle = linkStyle)
        } else {
            append(beforeText)
        }

        val urlObj = parseUrlStringSafe(
            url,
            // We only allow urls with internal hosts inside the markdown for now
            validateInternalHost = true
        )

        when {
            urlObj != null -> {
                // Markdown-style link
                if (addAnnotations) {
                    pushStringAnnotation(tag = AnnotationTagUrl, annotation = urlObj.toString())
                    withStyle(style = linkStyle) {
                        append(linkText ?: url)
                    }
                    pop()
                } else {
                    append(linkText ?: url)
                }
            }
            linkText != null -> {
                // url for markdown was probably invalid
                append(linkText)
            }
            fullMatch != null -> {
                // url was invalid, and no (valid) markdown was found
                // just show the full matched text
                append(fullMatch)
            }
        }

        lastEndIndex = endIndex
    }

    // Append any remaining text after the last match
    if (lastEndIndex < this@customLinkifyWithMarkdown.length) {
        val afterText = this@customLinkifyWithMarkdown.substring(lastEndIndex)
        if (addAnnotations) {
            this.linkify(text = afterText, linkStyle = linkStyle)
        } else {
            append(afterText)
        }
    }
}

fun AnnotatedString.hasAnyTag(tag: String) =
    this.getStringAnnotations(0, this.lastIndex).fastAny {
        it.tag == tag
    }

fun AnnotatedString.urlAt(position: Int, onFound: (String) -> Unit) =
    getStringAnnotations(AnnotationTagUrl, position, position).firstOrNull()?.item?.let {
        onFound(it)
    }

@Preview(showBackground = true)
@Composable
fun CustomLinkifyPreview() {
    val text = "some text example.com [click here](amigossocial.com) more text test.nl anothertest"

    val linkStyle = SpanStyle(textDecoration = TextDecoration.Underline)

    val linkifiedText = remember(text) {
        text.customLinkifyWithMarkdown(linkStyle)
    }

    val hasAnyLink = remember(linkifiedText) {
        linkifiedText.hasAnyTag(AnnotationTagUrl)
    }

    if (hasAnyLink) {
        Box(modifier = Modifier.background(CustomTheme.colorScheme.background)) {
            ClickableText(
                text = linkifiedText,
                style = CustomTheme.typography.subhead.copy(color = CustomTheme.colorScheme.onBackground),
                onClick = { position ->
                    linkifiedText.urlAt(position) {
                        println(it)
                    }
                },
            )
        }
    }
}