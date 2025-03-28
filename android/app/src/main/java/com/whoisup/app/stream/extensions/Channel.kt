package com.whoisup.app.stream.extensions

import io.getstream.chat.android.models.Channel

/**
 * Because Stream's `Channel.isDirectMessaging` implementation is incorrect,
 * we need our own custom extension method to be consistent with iOS implementation.
 */
fun Channel.isDirectMessageChannel(): Boolean {
    return id.startsWith("!members")
}

sealed class ChatChannelRelatedConceptType {
    data class Mixer(val id: String) : ChatChannelRelatedConceptType()
    data class Activity(val id: String) : ChatChannelRelatedConceptType()
    data object Standard : ChatChannelRelatedConceptType()
}

val Channel.relatedConceptType: ChatChannelRelatedConceptType
    get() = if (isDirectMessageChannel()) {
        ChatChannelRelatedConceptType.Standard
    } else {
        (extraData["mixerId"] as? String)?.let {
            ChatChannelRelatedConceptType.Mixer(it)
        } ?: ChatChannelRelatedConceptType.Activity(id)
    }