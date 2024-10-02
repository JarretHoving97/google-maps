package com.whoisup.app.stream

import android.Manifest
import android.os.Build
import android.util.Log
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.changedToUp
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.rememberMultiplePermissionsState
import com.whoisup.app.components.AmiIconButton
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.state.messages.attachments.StatefulStreamMediaRecorder
import io.getstream.chat.android.models.Attachment
import io.getstream.sdk.chat.audio.recording.MediaRecorderState
import kotlinx.coroutines.launch
import java.util.Date

// These components are entirely copied from stream.
// But those ones are marked internal unfortunately.

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun RecordAudioButton(
    statefulStreamMediaRecorder: StatefulStreamMediaRecorder,
    onRecordingSaved: (Attachment) -> Unit
) {
    val recordAudioButtonDescription = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_cd_record_audio_message)
    var permissionsRequested by rememberSaveable { mutableStateOf(false) }

    val isRecording = statefulStreamMediaRecorder.mediaRecorderState.value

    // TODO test permissions on lower APIs etc
    // @TODO permissions don't seem to work on Android 12 (I think due to `WRITE_EXTERNAL_STORAGE`)
    val storageAndRecordingPermissionState = rememberMultiplePermissionsState(
        permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            listOf(
                Manifest.permission.READ_MEDIA_AUDIO,
                Manifest.permission.RECORD_AUDIO,
            )
        } else {
            listOf(
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            )
        },
    ) {
        // TODO should we track this or always ask?
        permissionsRequested = true
    }
    val coroutineScope = rememberCoroutineScope()

    val context = LocalContext.current

    Box(
        modifier = Modifier
            .semantics { contentDescription = recordAudioButtonDescription }
            .pointerInput(Unit) {
                detectTapGestures(
                    onLongPress = {
                        /**
                         * An internal function used to handle audio recording. It initiates the recording
                         * and stops and saves the file once the appropriate gesture has been completed.
                         */
                        /**
                         * An internal function used to handle audio recording. It initiates the recording
                         * and stops and saves the file once the appropriate gesture has been completed.
                         */
                        fun handleAudioRecording() = coroutineScope.launch {
                            awaitPointerEventScope {
                                statefulStreamMediaRecorder.startAudioRecording(
                                    context = context,
                                    recordingName = "audio_recording_${Date()}",
                                )

                                while (true) {
                                    val event = awaitPointerEvent(PointerEventPass.Main)

                                    if (event.changes.all { it.changedToUp() }) {
                                        statefulStreamMediaRecorder
                                            .stopRecording()
                                            .onSuccess {
                                                // "[onRecordingSaved] attachment: $it"
                                                onRecordingSaved(it.attachment)
                                            }
                                            .onError {
                                                // "Could not save audio recording: ${it.message}"
                                            }
                                        break
                                    }
                                }
                            }
                        }

                        Log.d("kaasssoufle", "onlongpress")

                        when {
                            !storageAndRecordingPermissionState.allPermissionsGranted -> {
                                Log.d("kaasssoufle", "!allPermissionsGranted")
                                storageAndRecordingPermissionState.launchMultiplePermissionRequest()
                            }

                            isRecording == MediaRecorderState.UNINITIALIZED -> {
                                Log.d("kaasssoufle", "handleAudioRecording")
                                handleAudioRecording()
                            }

                            else -> {
                                Log.d("kaasssoufle", "Could not start audio recording")
                                // "Could not start audio recording"
                            }
                        }
                    },
                )
            },
        contentAlignment = Alignment.Center,
    ) {
        AmiIconButton(
            size = 40.dp,
            color = Color.Transparent,
            iconColor = if (isRecording == MediaRecorderState.RECORDING) {
                CustomTheme.colorScheme.primary
            } else {
                CustomTheme.colorScheme.onBackground
            },
            iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_mic_active,
        )
    }
}