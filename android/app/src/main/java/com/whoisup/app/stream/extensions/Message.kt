package com.whoisup.app.stream.extensions

import com.whoisup.app.stream.MessageLayoutKeyEnum
import io.getstream.chat.android.client.utils.message.isSystem
import io.getstream.chat.android.client.utils.message.isThreadStart
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.ui.common.state.messages.list.MessageItemState

/**
 * Helper function to determine if message is a thread start in an optimistic way.
 * That means:
 * - it's either a real thread start
 * - or it's the first (and probably only) message inside a thread view
 * This comes in handy to, for example, style the first message in a thread,
 * even if there are no other messages in that chat
 */
fun MessageItemState.isThreadStartOptimistic(): Boolean = this.message.isThreadStart() || this.isInThread && message.parentId.isNullOrEmpty()

fun Message.isAnonymousSystem(): Boolean {
    val isSystemMessage = this.isSystem()
    val layoutKey = this.extraData["layoutKey"] as? String
    return isSystemMessage && layoutKey == MessageLayoutKeyEnum.Anonymous.value
}