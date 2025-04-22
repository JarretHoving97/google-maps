package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import com.whoisup.app.stream.AmiChannelsScreen
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.models.InitializationState

class ChannelsActivity : BaseComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val activity = this

        // Check if there is a preselected channelId
        val channelId = intent.getStringExtra(KEY_CHANNEL_ID)

        if (channelId?.isBlank() == false) {
            // If so, start that activity
            startActivity(ChannelActivity.getIntent(this, channelId))
        }

        setContent {
            val clientInitialisationState by ChatClient.instance().clientState.initializationState.collectAsState()

            val context = LocalContext.current

            CustomTheme {
                when (clientInitialisationState) {
                    InitializationState.COMPLETE -> {
                        AmiChannelsScreen(
                            onChannelClick = { channel ->
                                ExtendedStreamPlugin.notifyNavigateToListeners(
                                    context,
                                    "/channels/${channel.cid}",
                                    false
                                )
                                startActivity(ChannelActivity.getIntent(this, channel.cid))
                            },
                            onMessageClick = { message ->
                                message.channelInfo?.cid?.let { cid ->
                                    ExtendedStreamPlugin.notifyNavigateToListeners(
                                        context,
                                        "/channels/${cid}",
                                        false
                                    )
                                    startActivity(ChannelActivity.getIntent(this, cid, message.id))
                                }
                            },
                            onBackClick = {
                                ExtendedStreamPlugin.notifyNavigateBackListeners(activity)
                                finish()
                            },
                            onBecomeSuperClick = {
                                val route = "/super-amigo"
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