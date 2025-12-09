package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import com.whoisup.app.stream.AmiChannelScreen
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.enableEdgeToEdgeCustom
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
import io.getstream.chat.android.models.InitializationState

class ChannelActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdgeCustom()

        val activity = this

        val channelId = intent.getStringExtra(KEY_CHANNEL_ID)

        if (channelId.isNullOrBlank()) {
            ExtendedStreamPlugin.notifyNavigateBackListeners(activity)
            finish()
            return
        }

        val messageId = intent.getStringExtra(KEY_MESSAGE_ID)

        setContent {
            val clientInitialisationState by ChatClient.instance().clientState.initializationState.collectAsState()

            val context = LocalContext.current

            CustomTheme {
                when (clientInitialisationState) {
                    InitializationState.COMPLETE -> {
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
                                ExtendedStreamPlugin.notifyNavigateBackListeners(activity)
                                finish()
                            },
                            onUserAvatarClick = {
                                val route = "/profile/${it}"
                                ExtendedStreamPlugin.notifyNavigateToListeners(context, route, true)
                            },
                            onWalkthroughClick = {
                                val route = if (it.isNullOrBlank()) {
                                    "/walkthrough"
                                } else {
                                    "/walkthrough/$it"
                                }
                                ExtendedStreamPlugin.notifyNavigateToListeners(context, route, true)
                            },
                            onBecomeSuperClick = {
                                val route = "/super-amigo"
                                ExtendedStreamPlugin.notifyNavigateToListeners(context, route, true)
                            },
                            onContactSupportClick = {
                                val route = "/faq"
                                ExtendedStreamPlugin.notifyNavigateToListeners(context, route, true)
                            },
                        )
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
