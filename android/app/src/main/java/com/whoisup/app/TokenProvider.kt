package com.whoisup.app

import android.content.Context
import com.whoisup.app.helpers.getJwt
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

fun loadStreamToken(context: Context): String {
    val jwt = getJwt(context) ?: return ""

    val url = BuildConfiguration.streamAuthTokenApiUrl

    val client = OkHttpClient()

    val request = Request.Builder()
        .url(url)
        .addHeader("Authorization", "Bearer $jwt")
        .addHeader("Content-Type", "application/json")
        .build()

    try {
        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                return@loadStreamToken ""
            }

            response.body?.string()?.let { bodyString ->
                try {
                    val jsonObject = JSONObject(bodyString)
                    val tokenString = jsonObject.optString("token")

                    if (tokenString.isNotBlank()) {
                        return@loadStreamToken tokenString
                    }
                } catch (e: Exception) {
                    // do nothing
                }
            }

            return@loadStreamToken ""
        }
    } catch(exception: Exception) {
        return ""
    }
}