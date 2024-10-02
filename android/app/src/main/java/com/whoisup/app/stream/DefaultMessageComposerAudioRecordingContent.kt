package com.whoisup.app.stream

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import io.getstream.chat.android.compose.state.messages.attachments.StatefulStreamMediaRecorder
import io.getstream.chat.android.compose.ui.attachments.audio.RunningWaveForm
import io.getstream.chat.android.compose.ui.theme.ChatTheme

// This component is entirely copied from stream.
// But that one is marked internal unfortunately.

/**
 * Used to display audio recording information while audio recording is in progress.
 *
 * @param statefulStreamMediaRecorder Used for recording audio messages.
 */
@Composable
fun RowScope.DefaultMessageComposerAudioRecordingContent(
    statefulStreamMediaRecorder: StatefulStreamMediaRecorder,
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier
            .align(Alignment.CenterVertically)
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .weight(1f),
    ) {
        val amplitudeSample = statefulStreamMediaRecorder.latestMaxAmplitude.value
        val recordingDuration = statefulStreamMediaRecorder.activeRecordingDuration.value

        val recordingDurationFormatted by remember(recordingDuration) {
            derivedStateOf {
                // TODO consider moving to common
                val remainder = recordingDuration % 60_000
                val seconds = String.format("%02d", remainder / 1000)
                val minutes = String.format("%02d", (recordingDuration - remainder) / 60_000)

                "$minutes:$seconds"
            }
        }

        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier
                .align(Alignment.CenterVertically),
        ) {
            Icon(
                modifier = Modifier
                    .size(12.dp)
                    .align(Alignment.CenterVertically),
                painter = painterResource(id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_circle),
                tint = Color.Red,
                // TODO add later
                contentDescription = null,
            )

            Text(
                modifier = Modifier.align(Alignment.CenterVertically),
                text = recordingDurationFormatted,
                style = ChatTheme.typography.body,
                color = ChatTheme.colors.textHighEmphasis,
            )
        }

        RunningWaveForm(
            modifier = Modifier
                .align(Alignment.CenterVertically)
                .fillMaxWidth()
                .height(20.dp),
            maxInputValue = 20_000,
            barWidth = 8.dp,
            barGap = 2.dp,
            restartKey = true,
            newValueKey = amplitudeSample.key,
            latestValue = amplitudeSample.value,
        )
    }
}