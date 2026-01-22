package com.whoisup.app

import android.content.Context
import com.whoisup.app.helpers.setUserId
import com.whoisup.app.helpers.unsetUserId
import com.whoisup.app.stream.extensions.isAnonymousSystem
import io.getstream.android.push.firebase.FirebasePushDeviceGenerator
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.client.logger.ChatLogLevel
import io.getstream.chat.android.client.notifications.handler.ChatNotification
import io.getstream.chat.android.client.notifications.handler.NotificationConfig
import io.getstream.chat.android.client.notifications.handler.NotificationHandlerFactory
import io.getstream.chat.android.client.token.TokenProvider
import io.getstream.chat.android.models.InitializationState
import io.getstream.chat.android.models.User
import io.getstream.chat.android.offline.plugin.factory.StreamOfflinePluginFactory
import io.getstream.chat.android.state.extensions.globalState
import io.getstream.chat.android.state.plugin.config.StatePluginConfig
import io.getstream.chat.android.state.plugin.factory.StreamStatePluginFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class Stream {
    companion object {
        private val job = Job()
        private val scope = CoroutineScope(job)

        @JvmStatic
        fun setup(applicationContext: Context) {
            // 1 - Set up the OfflinePlugin for offline storage
            val offlinePluginFactory = StreamOfflinePluginFactory(
                appContext = applicationContext,
            )
            val statePluginFactory = StreamStatePluginFactory(
                config = StatePluginConfig(
                    backgroundSyncEnabled = true,
                    userPresence = true,
                ),
                appContext = applicationContext,
            )

            val notificationConfig = NotificationConfig(
                ignorePushMessagesWhenUserOnline = false,
                requestPermissionOnAppLaunch = { false },
                pushDeviceGenerators = listOf(
                    FirebasePushDeviceGenerator(
                        providerName = "Firebase",
                        context = applicationContext
                    )
                )
            )

            val notificationHandler = NotificationHandlerFactory.createNotificationHandler(
                context = applicationContext,
                notificationConfig = notificationConfig,
                newMessageIntent = {
                        message,
                        channel,
                    ->
                    // Return the intent you want to be triggered when the notification is clicked
                    val parentMessageId = message.parentId
                    if (parentMessageId != null) {
                        val intent = ChannelThreadActivity.getIntent(applicationContext, channelId = channel.cid, messageId = message.id, parentMessageId)
                        // intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK) // @TODO(1)
                        intent
                    } else {
                        val intent = ChannelActivity.getIntent(applicationContext, channelId = channel.cid, messageId = message.id)
                        // intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK) // @TODO(1)
                        intent
                    }
                },
                notificationBuilderTransformer = { builder, notification ->
                    if (notification is ChatNotification.MessageNew) {
                        if (notification.message.isAnonymousSystem()) {
                            builder.setStyle(null)
                            builder.setContentTitle(notification.channel.name)
                            builder.setContentText(notification.message.text)
                        }
                    }
                    builder
                },
                notificationIdFactory = { notification ->
                    var notificationId: Int? = null
                    if (notification is ChatNotification.MessageNew) {
                        if (notification.message.isAnonymousSystem()) {
                            notificationId = "${notification.channel.type}:${notification.channel.id}:${notification.message.id}".hashCode()
                        }
                    }
                    notificationId
                }
            )

            // 2 - Set up the client for API calls and with the plugin for offline storage
            ChatClient.Builder(BuildConfiguration.streamApiKey, applicationContext)
                .notifications(notificationConfig, notificationHandler)
                .withPlugins(offlinePluginFactory, statePluginFactory)
                .logLevel(ChatLogLevel.NOTHING)
                .build()
        }

        fun logIn(
            context: Context,
            userId: String,
            name: String?,
            avatarUrl: String?
        ) {
            if (ChatClient.instance().clientState.initializationState.value != InitializationState.NOT_INITIALIZED) {
                // If SDK is already initialized or currently initializing,
                // do not initialize again.
                // It can cause crashes.
                // If explicitly needed to call `logIn` again,
                // instead call and await `logOut` first, and only then call `logIn` again.
                return
            }

            // 3 - Authenticate and connect the user
            val user = User(
                id = userId,
                name = name ?: "",
                image = avatarUrl ?: ""
            )

            val tokenProvider = object : TokenProvider {
                // Make a request to your backend to generate a valid token for the user.
                // It is expected that "yourTokenService.getToken" never throws an exception.
                // If the token cannot be loaded, it should return an empty string.
                override fun loadToken(): String = loadStreamToken(context)
            }

            val chatClient = ChatClient.instance()

            chatClient.connectUser(
                user = user,
                tokenProvider = tokenProvider
            ).enqueue { response ->
                if (response.isSuccess) {
                    setUserId(context, userId)

                    val initialChannelUnreadCount = chatClient.globalState.channelUnreadCount.value
                    val initialTotalUnreadCount = chatClient.globalState.totalUnreadCount.value
                    ExtendedStreamPlugin.shared?.notifyUnreadCountsListeners(initialChannelUnreadCount, initialTotalUnreadCount)

                    scope.launch {
                        chatClient.globalState.channelUnreadCount.collectLatest {
                            ExtendedStreamPlugin.shared?.notifyUnreadCountsListeners(
                                channelUnreadCount = it,
                                messageUnreadCount = null
                            )
                        }
                    }

                    scope.launch {
                        chatClient.globalState.totalUnreadCount.collectLatest {
                            ExtendedStreamPlugin.shared?.notifyUnreadCountsListeners(
                                channelUnreadCount = null,
                                messageUnreadCount = it
                            )
                        }
                    }
                }
            }
        }

        fun logOut(context: Context) {
            ChatClient.instance().disconnect(true).enqueue {
                if (it.isSuccess) {
                    unsetUserId(context)
                }
            }
        }
    }
}