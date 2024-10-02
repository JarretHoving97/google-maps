package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.DcIcon
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme

enum class AmiSafetyCheckInfoModalVariant {
    Sender,
    Receiver
}

private data class AmiSafetyCheckInfoModalContentData(
    val subtitle: String,
    val examples: List<AmiSafetyCheckInfoModalContentDataExample>
)

private data class AmiSafetyCheckInfoModalContentDataExample(
    val positive: Boolean,
    val key: String
)

@Composable
fun AmiSafetyCheckInfoModal(
    safetyCheckViewModel: SafetyCheckViewModel,
    receiverName: String,
    variant: AmiSafetyCheckInfoModalVariant,
) {
    val content = when (variant) {
        AmiSafetyCheckInfoModalVariant.Sender -> AmiSafetyCheckInfoModalContentData(
            subtitle = stringResource(R.string.SafetyCheckInfoModal_sender_subtitle, receiverName),
            examples = listOf(
                AmiSafetyCheckInfoModalContentDataExample(true, stringResource(R.string.SafetyCheckInfoModal_sender_examples_join)),
                AmiSafetyCheckInfoModalContentDataExample(true, stringResource(R.string.SafetyCheckInfoModal_sender_examples_host))
            )
        )
        else -> AmiSafetyCheckInfoModalContentData(
            subtitle = stringResource(R.string.SafetyCheckInfoModal_receiver_subtitle, receiverName),
            examples = listOf(
                AmiSafetyCheckInfoModalContentDataExample(true, stringResource(R.string.SafetyCheckInfoModal_receiver_examples_join)),
                AmiSafetyCheckInfoModalContentDataExample(true, stringResource(R.string.SafetyCheckInfoModal_receiver_examples_host)),
                AmiSafetyCheckInfoModalContentDataExample(false, stringResource(R.string.SafetyCheckInfoModal_receiver_examples_other))
            )
        )
    }

    val visible = safetyCheckViewModel.isInfoModalOpened

    val dismiss = remember(safetyCheckViewModel) { { safetyCheckViewModel.closeInfoModal() } }

    AmiSimpleMenu(
        visible = visible,
        onDismiss = dismiss
    ) {
        if (visible) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                AmiIconButton(
                    size = 120.dp,
                    color = CustomTheme.colorScheme.primary,
                    iconId = R.drawable.safety_shield_check_filled,
                )

                BasicText(
                    text = stringResource(R.string.SafetyCheckInfoModal_title),
                    style = CustomTheme.typography.headingMedium.copy(color = CustomTheme.colorScheme.onBackground)
                )

                BasicText(
                    text = content.subtitle,
                    style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground)
                )

                if (content.examples.isNotEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(CustomTheme.colorScheme.surface)
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        content.examples.forEach { example ->
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                DcIcon(
                                    id = if (example.positive) {
                                        R.drawable.check
                                    } else {
                                        R.drawable.close
                                    },
                                    contentDescription = null,
                                    size = 16.dp,
                                    color = if (example.positive) {
                                        CustomTheme.colorScheme.success
                                    } else {
                                        CustomTheme.colorScheme.danger
                                    },
                                )
                                BasicText(
                                    text = example.key,
                                    style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onSurface)
                                )
                            }
                        }
                    }
                }

                AmiButton(
                    text = stringResource(R.string.global_iUnderstand),
                    onClick = dismiss,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}