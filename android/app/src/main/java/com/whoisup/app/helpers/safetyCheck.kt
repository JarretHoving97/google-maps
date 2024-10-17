package com.whoisup.app.helpers

import android.content.Context
import com.whoisup.app.stream.UserNegativeReviewReasonEnum

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

fun addPositiveSafetyCheck(
    context: Context,
    userId: String
): Boolean {
    val body = getRequestBodyForPositive(userId)

    return executeGraphqlCall(context, body) != null
}

fun addNegativeSafetyCheck(
    context: Context,
    userId: String,
    reason: UserNegativeReviewReasonEnum
): Boolean {
    val body = getRequestBodyForNegative(userId, reason)

    return executeGraphqlCall(context, body) != null
}