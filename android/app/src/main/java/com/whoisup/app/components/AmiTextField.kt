package com.whoisup.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onPreInterceptKeyBeforeSoftKeyboard
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun AmiTextField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String? = null,
    maxLength: Int = Int.MAX_VALUE,
    singleLine: Boolean = false,
    maxLines: Int = if (singleLine) 1 else Int.MAX_VALUE,
    minLines: Int = 1,
    onFocusChange: (Boolean) -> Unit = {},
    headingContent: @Composable () -> Unit = {},
    leadingContent: @Composable () -> Unit = {},
    trailingContent: @Composable () -> Unit = {}
) {
    var isFocused by remember { mutableStateOf(false) }

    val focusManager = LocalFocusManager.current

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .border(
                2.dp,
                if (isFocused) {
                    CustomTheme.colorScheme.primary
                } else {
                    CustomTheme.colorScheme.surfaceHard
                },
                RoundedCornerShape(8.dp)
            )
            .background(CustomTheme.colorScheme.background)
    ) {
        headingContent()

        Row(verticalAlignment = Alignment.CenterVertically) {
            leadingContent()

            BasicTextField(
                value = value,
                onValueChange = {
                    if (value != it) {
                        val text = it.substring(0, maxLength.coerceAtMost(it.length))
                        onValueChange(text)
                    }
                },
                modifier = Modifier
                    .weight(1f)
                    .padding(
                        horizontal = 16.dp,
                        vertical = 16.dp
                    )
                    .onFocusChanged {
                        isFocused = it.isFocused
                        onFocusChange(isFocused)
                    }
                    .onPreInterceptKeyBeforeSoftKeyboard {
                        if (it.key.keyCode == 17179869184) {
                            focusManager.clearFocus()
                        }
                        false
                    },
                textStyle = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground),
                keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
                keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
                singleLine = singleLine,
                maxLines = maxLines,
                minLines = minLines,
                cursorBrush = SolidColor(CustomTheme.colorScheme.onBackground)
            ) { innerTextField ->
                if (value.isEmpty()) {
                    BasicText(
                        text = placeholder ?: "",
                        style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onSurfaceSoft),
                    )
                }
                innerTextField()
            }

            trailingContent()
        }
    }
}