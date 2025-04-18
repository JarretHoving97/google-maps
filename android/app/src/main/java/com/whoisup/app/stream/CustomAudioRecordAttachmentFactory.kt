package com.whoisup.app.stream

import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.res.stringResource
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.whoisup.app.R
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.client.utils.attachment.isAudioRecording
import io.getstream.chat.android.compose.ui.attachments.content.AudioRecordAttachmentContent
import io.getstream.chat.android.compose.ui.attachments.content.AudioRecordAttachmentPreviewContentItem
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.AudioPlayerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.AudioPlayerViewModelFactory
import io.getstream.chat.android.core.internal.InternalStreamChatApi

@OptIn(InternalStreamChatApi::class)
class CustomAudioRecordAttachmentFactory(
    private val viewModelFactory: AudioPlayerViewModelFactory = AudioPlayerViewModelFactory(
        getAudioPlayer = { ChatClient.instance().audioPlayer },
        getRecordingUri = { it.assetUrl ?: it.upload?.toUri()?.toString() },
    ),
    private val getCurrentUserId: () -> String? = { ChatClient.instance().getCurrentOrStoredUserId() },
) : AmiAttachmentFactory(
    canHandle = {
        it.isAudioRecording()
    },
    previewText = @Composable { _ ->
        AttachmentContent(
            iconId = R.drawable.attachment_file,
            description = stringResource(id = R.string.custom_attachment_tag_file)
        )
    },
    previewContent = @Composable { attachment, onAttachmentRemoved ->
        val viewModel = viewModel(AudioPlayerViewModel::class.java, factory = viewModelFactory)

        val playerState by viewModel.state.collectAsStateWithLifecycle()

        AudioRecordAttachmentPreviewContentItem(
            attachment = attachment,
            playerState = playerState,
            onPlayToggleClick = {
                viewModel.playOrPause(it)
            },
            onThumbDragStart = {
                viewModel.startSeek(it)
            },
            onThumbDragStop = { it, progress ->
                viewModel.seekTo(it, progress)
            },
            onAttachmentRemoved = {
                viewModel.reset(it)
                onAttachmentRemoved(it)
            },
        )
    },
    content = @Composable { modifier, attachmentState ->
        AudioRecordAttachmentContent(
            modifier = modifier
                .wrapContentHeight()
                .width(ChatTheme.dimens.attachmentsContentUnsupportedWidth),
            attachmentState = attachmentState,
            viewModelFactory = viewModelFactory,
            getCurrentUserId = getCurrentUserId,
        )
    },
    quotedContent = null
)
