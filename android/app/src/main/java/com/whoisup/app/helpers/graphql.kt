package com.whoisup.app.helpers

import android.content.Context
import com.whoisup.app.BuildConfiguration
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

fun executeGraphqlCall(
    context: Context,
    body: String,
): JSONObject? {
    val jwt = getJwt(context) ?: return null

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
        if (!response.isSuccessful) {
            return@executeGraphqlCall null
        }

        response.body?.string()?.let { bodyString ->
            try {
                return@executeGraphqlCall JSONObject(bodyString)
            } catch (e: Exception) {
                // do nothing
            }
        }

        return@executeGraphqlCall null
    }
}