package com.whoisup.app.helpers

import android.content.Context
import com.whitestein.securestorage.PasswordStorageHelper
import java.nio.charset.Charset

private fun getValueFromPasswordStorageHelper(context: Context, key: String): String? {
    val passwordStorageHelper = PasswordStorageHelper(context)

    val buffer = passwordStorageHelper.getData(key)

    return if (buffer != null) {
        String(buffer, Charset.forName("UTF-8"))
    } else {
        // "Item with given key does not exist"
        null
    }
}

fun getJwt(context: Context): String? {
    return getValueFromPasswordStorageHelper(context, "jwt")
}

const val USER_ID_KEY = "userId"

fun setUserId(context: Context, userId: String) {
    val passwordStorageHelper = PasswordStorageHelper(context)
    passwordStorageHelper.setData(USER_ID_KEY, userId.toByteArray(Charset.forName("UTF-8")))
}

fun getUserId(context: Context): String? {
    return getValueFromPasswordStorageHelper(context, USER_ID_KEY)
}

fun unsetUserId(context: Context) {
    val passwordStorageHelper = PasswordStorageHelper(context)
    val buffer: ByteArray? = passwordStorageHelper.getData(USER_ID_KEY)
    if (buffer != null) {
        passwordStorageHelper.remove(USER_ID_KEY)
    }
}