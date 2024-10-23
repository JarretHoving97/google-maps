package com.whoisup.app.helpers

import android.content.Context

private fun getRequestBodyForFindOrCreateChat(receiverId: String): String {
    return """
    {
      "operationName": "FindOrCreateChat",
      "variables": {
        "input": {
          "receiverId": "$receiverId"
        }
      },
      "query": "mutation FindOrCreateChat(${'$'}input: FindOrCreateChatInput!) { findOrCreateChat(input: ${'$'}input) { __typename channelId } }"
    }
    """
}

fun findOrCreateChat(
    context: Context,
    receiverId: String
): String? {
    val body = getRequestBodyForFindOrCreateChat(receiverId)

    val json = executeGraphqlCall(context, body)

    try {
        val data = json?.optJSONObject("data")
        val findOrCreateChat = data?.optJSONObject("findOrCreateChat")
        return findOrCreateChat?.optString("channelId")
    } catch (e: Exception) {
        // do nothing
    }

    return null
}
