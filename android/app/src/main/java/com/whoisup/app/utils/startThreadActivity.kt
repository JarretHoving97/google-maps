package com.whoisup.app.utils

import android.content.Context
import com.whoisup.app.ChannelThreadActivity

fun startThreadActivity(context: Context, channelId: String, messageId: String, parentMessageId: String?) {
    if (parentMessageId != null) {
        // Apparently this isn't the first message in the thread,
        // so open the thread and focus on this message
        context.startActivity(
            ChannelThreadActivity.getIntent(
                context,
                channelId,
                messageId,
                parentMessageId
            )
        )
    } else {
        // Otherwise just open the thread without focusing anything.
        // Mind you, that since no parent id is present, the messageId itself automatically also becomes the parentMessageId
        context.startActivity(
            ChannelThreadActivity.getIntent(
                context,
                channelId,
                null,
                messageId
            )
        )
    }
}