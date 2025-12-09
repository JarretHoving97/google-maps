package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import com.whoisup.app.stream.AmiChannelThreadScreen
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.enableEdgeToEdgeCustom
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
import io.getstream.chat.android.models.InitializationState

class ChannelThreadActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdgeCustom()

        val activity = this

        val channelId = intent.getStringExtra(KEY_CHANNEL_ID)
        val messageId = intent.getStringExtra(KEY_MESSAGE_ID)
        val parentMessageId = intent.getStringExtra(KEY_PARENT_MESSAGE_ID)

        if (channelId.isNullOrBlank() || parentMessageId.isNullOrBlank()) {
            // ExtendedStreamPlugin.notifyNavigateBackListeners(activity) // only enable this line when it becomes a real route in the web client as well
            finish()
            return
        }

        setContent {
            val clientInitialisationState by ChatClient.instance().clientState.initializationState.collectAsState()

            val context = LocalContext.current

            CustomTheme {
                when (clientInitialisationState) {
                    InitializationState.COMPLETE -> {
                        AmiChannelThreadScreen(
                            parentMessageId = parentMessageId,
                            viewModelFactory = MessagesViewModelFactory(
                                context = this,
                                channelId = channelId,
                                messageId = messageId,
                                parentMessageId = parentMessageId
                            ),
                            // @TODO: whenever stream fixes the stuff with the voice recorder,
                            // re-enable this
                            // statefulStreamMediaRecorder = StatefulStreamMediaRecorder(streamMediaRecorder = ChatTheme.streamMediaRecorder),
                            onBackClick = {
                                // ExtendedStreamPlugin.notifyNavigateBackListeners(activity) // only enable this line when it becomes a real route in the web client as well
                                if (ExtendedStreamPlugin.shared == null && activity.isTaskRoot) {
                                    activity.startActivity(Intent(activity, MainActivity::class.java))
                                }
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
        private const val KEY_PARENT_MESSAGE_ID = "parentMessageId"

        /**
         * @param messageId Optionally provide this intent with the message to focus on. This can be the parent message.
         */
        @JvmStatic
        fun getIntent(context: Context, channelId: String, messageId: String?, parentMessageId: String): Intent {
            return Intent(context, ChannelThreadActivity::class.java).apply {
                putExtra(KEY_CHANNEL_ID, channelId)
                putExtra(KEY_MESSAGE_ID, messageId)
                putExtra(KEY_PARENT_MESSAGE_ID, parentMessageId)
            }
        }
    }
}
