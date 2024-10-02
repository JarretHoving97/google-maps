package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.helpers.addPositiveSafetyCheck
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.models.User
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Composable
fun AmiSafetyCheckChatNotice(
    safetyCheckViewModel: SafetyCheckViewModel,
    otherUser: User,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(CustomTheme.colorScheme.surface)
            .padding(16.dp)
            .pointerInput(Unit) {},
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AmiIconButton(
            size = 40.dp,
            color = CustomTheme.colorScheme.primary,
            iconId = R.drawable.safety_shield_check_filled,
            onClick = {
                safetyCheckViewModel.openInfoModal()
            },
        )

        BasicText(
            text = stringResource(id = R.string.custom_safetyCheck_notice_title, otherUser.name),
            modifier = Modifier.weight(1f),
            style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface)
        )

        AmiIconButton(
            size = 40.dp,
            color = CustomTheme.colorScheme.danger,
            iconColor = CustomTheme.colorScheme.onDanger,
            iconId = R.drawable.thumbs_down,
            onClick = {
                safetyCheckViewModel.openModal()
            },
        )

        val context = LocalContext.current

        val coroutineScope = rememberCoroutineScope()

        AmiIconButton(
            size = 40.dp,
            color = CustomTheme.colorScheme.success,
            iconColor = CustomTheme.colorScheme.onSuccess,
            iconId = R.drawable.thumbs_up,
            onClick = {
                coroutineScope.launch(Dispatchers.Default) {
                    addPositiveSafetyCheck(context, otherUser.id)
                }
            },
        )
    }
}