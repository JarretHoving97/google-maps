package com.whoisup.app

import com.capacitorjs.plugins.pushnotifications.PushNotificationsPlugin
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.getstream.android.push.firebase.FirebaseMessagingDelegate

class CustomFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        val remoteMessageHandledByStream = try {
            if (FirebaseMessagingDelegate.handleRemoteMessage(remoteMessage)) {
                // RemoteMessage was from Stream and it is already processed
                true
            } else {
                // RemoteMessage wasn't sent from Stream and it needs to be handled by you
                false
            }
        } catch (exception: IllegalStateException) {
            // ChatClient was not initialized
            false
        }

        if (!remoteMessageHandledByStream) {
            PushNotificationsPlugin.sendRemoteMessage(remoteMessage)
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)

        // Update device's token on Stream backend
        try {
            FirebaseMessagingDelegate.registerFirebaseToken(token, "Firebase")
        } catch (exception: IllegalStateException) {
            // ChatClient was not initialized
        }

        PushNotificationsPlugin.onNewToken(token)
    }
}

