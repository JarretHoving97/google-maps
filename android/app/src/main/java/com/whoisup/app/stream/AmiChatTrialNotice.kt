package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.SuperEntitlementStatus
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiSimpleDialogDrawer
import com.whoisup.app.components.DcIcon
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import java.time.Duration
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.temporal.ChronoUnit

@Composable
fun AmiChatTrialNotice(
    onBecomeSuperClick: () -> Unit
) {
    var showDialog by remember { mutableStateOf(false) }

    val now = ZonedDateTime.now(ZoneId.systemDefault())
    val chatTrialUntil = ExtendedStreamPlugin.shared?.chatTrialUntil

    val remainingTrialDays = if (ExtendedStreamPlugin.shared?.superEntitlementStatus == SuperEntitlementStatus.Available && chatTrialUntil != null) {
        Duration.between(
            now.truncatedTo(ChronoUnit.DAYS),
            chatTrialUntil.truncatedTo(ChronoUnit.DAYS)
        ).toDays()
    } else {
        null
    }

    val maxTrailDays = 30

    if (remainingTrialDays != null && remainingTrialDays > 0) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp)
                .padding(horizontal = 8.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(CustomTheme.colorScheme.surface)
                .clickable(onClick = {
                    showDialog = true
                })
                .padding(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(CustomTheme.colorScheme.surfaceHard),
                    contentAlignment = Alignment.Center
                ) {
                    BasicText(
                        text = "$remainingTrialDays",
                        style = CustomTheme.typography.headingMedium.copy(color = CustomTheme.colorScheme.onSurface),
                    )
                }

                BasicText(
                    text = pluralStringResource(
                        id = R.plurals.AmiChatTrialNotice_title,
                        count = remainingTrialDays.toInt(),
                        remainingTrialDays.toInt()
                    ),
                    style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface),
                    modifier = Modifier.weight(1f)
                )

                DcIcon(
                    id = R.drawable.angle_right,
                    contentDescription = null,
                    size = 12.dp,
                    color = CustomTheme.colorScheme.primary
                )
            }

            val showProgressBar = remainingTrialDays <= maxTrailDays

            if (showProgressBar) {
                val progress =
                    (remainingTrialDays.toFloat() / maxTrailDays.toFloat()).coerceAtMost(1f)

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(CustomTheme.colorScheme.surfaceHard)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(progress)
                            .height(8.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(CustomTheme.colorScheme.primary)
                    )
                }
            }
        }
    }

    AmiSimpleDialogDrawer(
        showDialog = showDialog,
        onDismissRequest = { showDialog = false }
    ) {
        if (showDialog) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .pointerInput(Unit) {}
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(180.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .background(CustomTheme.colorScheme.surface)
                        .padding(12.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(CustomTheme.colorScheme.surfaceHard),
                    contentAlignment = Alignment.Center
                ) {
                    BasicText(
                        text = "$maxTrailDays",
                        style = CustomTheme.typography.headingExtraLarge.copy(color = CustomTheme.colorScheme.onSurface, fontSize = 80.sp),
                    )
                }

                BasicText(
                    text = stringResource(id = R.string.AmiChatTrialNotice_dialog_title, maxTrailDays),
                    modifier = Modifier.fillMaxWidth(),
                    style = CustomTheme.typography.headingExtraLarge.copy(color = CustomTheme.colorScheme.onBackground),
                )

                BasicText(
                    text = stringResource(id = R.string.AmiChatTrialNotice_dialog_body, maxTrailDays),
                    modifier = Modifier.fillMaxWidth(),
                    style = CustomTheme.typography.paragraph.copy(color = CustomTheme.colorScheme.onBackground),
                )

                AmiButton(
                    text = stringResource(id = R.string.global_becomeSuperAmigo),
                    onClick = onBecomeSuperClick,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }
}