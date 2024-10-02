package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.whoisup.app.stream.AmiChannelScreen
import com.whoisup.app.stream.CustomChatTheme
import com.whoisup.app.stream.MediaGalleryPreviewContract
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
import io.getstream.chat.android.models.InitializationState

class ChannelActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val channelId = intent.getStringExtra(KEY_CHANNEL_ID)

        if (channelId.isNullOrBlank()) {
            ExtendedStreamPlugin.shared?.notifyNavigateBackListeners()
            finish()
            return
        }

        val messageId = intent.getStringExtra(KEY_MESSAGE_ID)

        setContent {
            val clientInitialisationState by ChatClient.instance().clientState.initializationState.collectAsState()

            CustomTheme {
                val mediaGalleryPreviewLauncher = rememberLauncherForActivityResult(
                    contract = MediaGalleryPreviewContract(),
                    onResult = {
                        // If we ever want to implement "show in chat" or actions like that,
                        // we can use this callback for that.
                    },
                )

                when (clientInitialisationState) {
                    InitializationState.COMPLETE -> {
                        CustomChatTheme(mediaGalleryPreviewLauncher) {
                            AmiChannelScreen(
                                viewModelFactory = MessagesViewModelFactory(
                                    context = this,
                                    channelId = channelId,
                                    messageId = messageId
                                ),
                                // @TODO: whenever stream fixes the stuff with the voice recorder,
                                // re-enable this
                                // statefulStreamMediaRecorder = StatefulStreamMediaRecorder(streamMediaRecorder = ChatTheme.streamMediaRecorder),
                                onBackClick = {
                                    ExtendedStreamPlugin.shared?.notifyNavigateBackListeners()
                                    finish()
                                },
                                onUserAvatarClick = {
                                    val route = "/profile/${it}"
                                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                                },
                                onWalkthroughClick = {
                                    val route = if (it.isNullOrBlank()) {
                                        "/walkthrough"
                                    } else {
                                        "/walkthrough/$it"
                                    }
                                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                                },
                                onBecomeSuperClick = {
                                    val route = "/super-amigo"
                                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                                },
                                onContactSupportClick = {
                                    val route = "/faq"
                                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(route, false, true)
                                },
                            )
                        }
                    }

                    InitializationState.INITIALIZING -> {
                        // @TODO
                    }

                    InitializationState.NOT_INITIALIZED -> {
                        // @TODO
                    }
                }
            }
        }
    }

    companion object {
        private const val KEY_CHANNEL_ID = "channelId"
        private const val KEY_MESSAGE_ID = "messageId"

        @JvmStatic
        fun getIntent(context: Context, channelId: String, messageId: String? = null): Intent {
            return Intent(context, ChannelActivity::class.java).apply {
                putExtra(KEY_CHANNEL_ID, channelId)

                if (messageId != null) {
                    putExtra(KEY_MESSAGE_ID, messageId)
                }
            }
        }
    }
}
