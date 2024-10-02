package com.whoisup.app.helpers

import android.content.Context
import com.whoisup.app.BuildConfiguration
import com.whoisup.app.stream.UserNegativeReviewReasonEnum
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

private fun getRequestBodyForPositive(userId: String): String {
    return """
    {
      "operationName": "AddUserPositiveReview",
      "variables": {
        "input": {
          "userId": "$userId"
        }
      },
      "query": "mutation AddUserPositiveReview(${'$'}input: AddUserPositiveReviewInput!) {addUserPositiveReview(input: ${'$'}input){__typename success}}"
    }
    """
}

private fun getRequestBodyForNegative(userId: String, reason: UserNegativeReviewReasonEnum): String {
    return """
    {
      "operationName": "AddUserNegativeReview",
      "variables": {
        "input": {
          "userId": "$userId",
          "reason": "${reason.value}",
          "message": null
        }
      },
      "query": "mutation AddUserNegativeReview(${'$'}input: AddUserNegativeReviewInput!) {addUserNegativeReview(input: ${'$'}input) {__typename success }}"
    }
    """
}

private fun updateSafetyCheck(
    context: Context,
    body: String,
): Boolean {
    val jwt = getJwt(context) ?: return false

    val url = "${BuildConfiguration.amigosApiUrl}/graphql"

    val client = OkHttpClient()

    val requestBody = body.toRequestBody("application/json".toMediaTypeOrNull())

    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .addHeader("Authorization", "Bearer $jwt")
        .addHeader("Content-Type", "application/json")
        .build()

    client.newCall(request).execute().use { response ->
        return@updateSafetyCheck response.isSuccessful
    }
}

fun addPositiveSafetyCheck(
    context: Context,
    userId: String
): Boolean {
    val body = getRequestBodyForPositive(userId)

    return updateSafetyCheck(context, body)
}

fun addNegativeSafetyCheck(
    context: Context,
    userId: String,
    reason: UserNegativeReviewReasonEnum
): Boolean {
    val body = getRequestBodyForNegative(userId, reason)

    return updateSafetyCheck(context, body)
}