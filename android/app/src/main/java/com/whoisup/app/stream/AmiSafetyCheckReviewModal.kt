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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiRadioButton
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.DcIcon
import com.whoisup.app.helpers.addNegativeSafetyCheck
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.models.User
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

enum class UserNegativeReviewReasonEnum(val value: String) {
    Commercial("COMMERCIAL"),
    Dating("DATING"),
    InappropriateLanguage("INAPPROPRIATE_LANGUAGE"),
    Other("OTHER"),
    Spam("SPAM")
}

data class SafetyCheckOption(val key: UserNegativeReviewReasonEnum, val label: String)

@Composable
fun AmiSafetyCheckReviewModal(
    otherUser: User,
    safetyCheckViewModel: SafetyCheckViewModel,
) {
    AmiSimpleMenu(visible = safetyCheckViewModel.isModalOpened, onDismiss = { safetyCheckViewModel.closeModal() }) {
        if (safetyCheckViewModel.isModalOpened) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                BasicText(
                    text = stringResource(id = R.string.custom_safetyCheck_review_sheet_title),
                    style = CustomTheme.typography.headingExtraLarge.copy(color = CustomTheme.colorScheme.onBackground),
                )

                BasicText(
                    text = stringResource(id = R.string.custom_safetyCheck_review_sheet_subtitle),
                    style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground),
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(CustomTheme.colorScheme.surface)
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    DcIcon(id = R.drawable.safety_shield_check_filled, contentDescription = null, size = 32.dp)

                    BasicText(
                        text = stringResource(id = R.string.custom_safetyCheck_review_sheet_tip),
                        modifier = Modifier.weight(1f),
                        style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface)
                    )
                }

                var selectedOption by remember { mutableStateOf<UserNegativeReviewReasonEnum?>(null) }

                var loading by rememberSaveable { mutableStateOf(false) }

                val options = listOf(
                    SafetyCheckOption(
                        key = UserNegativeReviewReasonEnum.Commercial,
                        label = stringResource(id = R.string.custom_safetyCheck_review_sheet_option_commercial)
                    ),
                    SafetyCheckOption(
                        key = UserNegativeReviewReasonEnum.Dating,
                        label = stringResource(id = R.string.custom_safetyCheck_review_sheet_option_dating)
                    ),
                    SafetyCheckOption(
                        key = UserNegativeReviewReasonEnum.InappropriateLanguage,
                        label = stringResource(id = R.string.custom_safetyCheck_review_sheet_option_inappropriateLanguage)
                    ),
                    SafetyCheckOption(
                        key = UserNegativeReviewReasonEnum.Spam,
                        label = stringResource(id = R.string.custom_safetyCheck_review_sheet_option_spam)
                    ),
                    SafetyCheckOption(
                        key = UserNegativeReviewReasonEnum.Other,
                        label = stringResource(id = R.string.custom_safetyCheck_review_sheet_option_other)
                    ),
                )

                options.forEach { option ->
                    AmiRadioButton(
                        label = option.label,
                        checked = selectedOption == option.key,
                        onCheckedChanged = { checked ->
                            selectedOption = if (checked == true) {
                                option.key
                            } else {
                                null
                            }
                        }
                    )
                }

                val context = LocalContext.current

                val coroutineScope = rememberCoroutineScope()

                AmiButton(
                    text = stringResource(id = R.string.global_confirm),
                    onClick = {
                        coroutineScope.launch(Dispatchers.Default) {
                            loading = true
                            selectedOption?.let {
                                if (addNegativeSafetyCheck(
                                    context = context,
                                    userId = otherUser.id,
                                    reason = it
                                )) {
                                    safetyCheckViewModel.closeModal()
                                }
                            }
                            loading = false
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = selectedOption != null,
                    loading = loading
                )
            }
        }
    }
}