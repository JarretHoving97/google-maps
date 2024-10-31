package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.whoisup.app.stream.AmiChannelsScreen
import com.whoisup.app.stream.CustomChatTheme
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.models.InitializationState

class ChannelsActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if there is a preselected channelId
        val channelId = intent.getStringExtra(KEY_CHANNEL_ID)

        if (channelId?.isBlank() == false) {
            // If so, start that activity
            startActivity(ChannelActivity.getIntent(this, channelId))
        }

        setContent {
            val clientInitialisationState by ChatClient.instance().clientState.initializationState.collectAsState()

            CustomTheme {
                when (clientInitialisationState) {
                    InitializationState.COMPLETE -> {
                        CustomChatTheme {
                            AmiChannelsScreen(
                                onChannelClick = { channel ->
                                    ExtendedStreamPlugin.shared?.notifyNavigateToListeners(
                                        "/channels/${channel.cid}",
                                        false,
                                        false
                                    )
                                    startActivity(ChannelActivity.getIntent(this, channel.cid))
                                },
                                onMessageClick = { message ->
                                    message.channelInfo?.cid?.let { cid ->
                                        ExtendedStreamPlugin.shared?.notifyNavigateToListeners(
                                            "/channels/${cid}",
                                            false,
                                            false
                                        )
                                        startActivity(ChannelActivity.getIntent(this, cid, message.id))
                                    }
                                },
                                onBackClick = {
                                    ExtendedStreamPlugin.shared?.notifyNavigateBackListeners()
                                    finish()
                                },
                                onBecomeSuperClick = {
                                    val route = "/super-amigo"
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

        @JvmStatic
        fun getIntent(context: Context, channelId: String? = null): Intent {
            return Intent(context, ChannelsActivity::class.java).apply {
                if (channelId != null) {
                    putExtra(KEY_CHANNEL_ID, channelId)
                }
            }
        }
    }
}