package com.whoisup.app.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.whoisup.app.ui.theme.CustomTheme

@Composable
fun AmiRadioButton(
    label: String,
    checked: Boolean?,
    onCheckedChanged: (checked: Boolean?) -> Unit,
    disabled: Boolean = false
) {
    val interactionSource = remember { MutableInteractionSource() }

    val onClick = remember(checked, disabled) {
        {
            if (!disabled) {
                onCheckedChanged(checked != true)
            }
        }
    }

    Row(
        modifier = Modifier
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AmiRadioButtonIcon(
            checked = checked,
            modifier = Modifier
                .clickable(
                    interactionSource = interactionSource,
                    indication = ripple(),
                    onClick = onClick
                ),
            disabled = disabled
        )

        BasicText(
            text = label,
            modifier = Modifier.weight(1f),
            style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground)
        )
    }
}

@Preview(showBackground = true)
@Composable
fun AmiCheckboxPreview() {
    var value: Boolean? by rememberSaveable { mutableStateOf(null) }

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        AmiRadioButton(label = "Option 1", checked = value, onCheckedChanged = { value = it })
        AmiRadioButton(
            label = "Option 2",
            checked = value,
            onCheckedChanged = { value = it },
            disabled = true
        )
    }
}
