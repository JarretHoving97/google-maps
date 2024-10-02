package com.whoisup.app.stream.extensions

import io.getstream.chat.android.models.Channel

/**
 * Because Stream's `Channel.isDirectMessaging` implementation is incorrect,
 * we need our own custom extension method to be consistent with iOS implementation.
 */
fun Channel.isDirectMessageChannel(): Boolean {
    return id.startsWith("!members")
}