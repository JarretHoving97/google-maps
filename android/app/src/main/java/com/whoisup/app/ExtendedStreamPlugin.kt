package com.whoisup.app

import android.content.Intent
import android.webkit.WebView
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import java.util.Locale
import kotlin.coroutines.resume

enum class SuperEntitlementStatus {
    Unavailable,
    Available,
    Active
}

@CapacitorPlugin(name = "ExtendedStream")
class ExtendedStreamPlugin : Plugin() {
    override fun load() {
        shared = this
    }

    var locale: Locale? = null

    @PluginMethod
    fun openChannels(call: PluginCall) {
        val channelId = call.getString("channelId")

        if (channelId != null) {
            context.startActivity(ChannelsActivity.getIntent(context, channelId))
        } else {
            context.startActivity(ChannelsActivity.getIntent(context, null))
        }

        call.resolve()
    }

    @PluginMethod
    fun openChannel(call: PluginCall) {
        val channelId = call.getString("channelId")

        if (channelId != null) {
//            messaging:tutorial-app-channel-11
//            messaging:tutorial-app-channel-13
//            messaging:tutorial-app-channel-4
//            messaging:tutorial-app-channel-5
//            messaging:tutorial-app-channel-9
            context.startActivity(ChannelActivity.getIntent(context, channelId))
        }

        call.resolve()
    }

    @PluginMethod
    fun logIn(call: PluginCall) {
        val userId = call.getString("userId")
        val name = call.getString("name")
        val avatarUrl = call.getString("avatarUrl")

        if (userId != null) {
            Stream.logIn(
                context,
                userId,
                name,
                avatarUrl
            )
        }
    }

    @PluginMethod
    fun logOut(call: PluginCall) {
        Stream.logOut(context)
    }

    var superEntitlementStatus: SuperEntitlementStatus = SuperEntitlementStatus.Unavailable

    @PluginMethod
    fun setEntitlementDetails(call: PluginCall) {
        val superStatus = call.getString("superStatus")

        superEntitlementStatus = superStatus?.let { SuperEntitlementStatus.valueOf(it) } ?: superEntitlementStatus

        call.resolve()
    }

    @PluginMethod
    fun setLanguage(call: PluginCall) {
        val code = call.getString("code")

        if (code.isNullOrBlank()) {
            println("[ExtendedStream] Invalid language code: $code")
            return call.resolve()
        }

        locale = Locale.forLanguageTag(code)

        call.resolve()
    }

    fun notifyNavigateToListeners(route: String, replace: Boolean, dismiss: Boolean) {
        val jsObject = JSObject()
        jsObject.put("route", route)
        jsObject.put("replace", replace)
        notifyListeners("navigateTo", jsObject)

        if (dismiss) {
            // finish()
            // finishAffinity()
            val intent = Intent(
                bridge.context,
                MainActivity::class.java
            )
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.putExtra("EXIT", true)
            bridge.context.startActivity(intent)
        }
    }

    fun notifyNavigateBackListeners() {
        notifyListeners("navigateBack", JSObject())
    }

    fun notifyUnreadCountsListeners(channelUnreadCount: Int?, messageUnreadCount: Int?) {
        val jsObject = JSObject()
        if (channelUnreadCount != null) {
            jsObject.put("channelUnreadCount", channelUnreadCount)
        }
        if (messageUnreadCount != null) {
            jsObject.put("messageUnreadCount", messageUnreadCount)
        }
        notifyListeners("unreadCounts", jsObject)
    }

    suspend fun translate(key: String, namespace: String, options: Map<String, String> = emptyMap()): String? {
        return try {
            val optionsJson = JSONObject(options).toString()
            val jsScript = "window.translate(\"$key\", \"$namespace\", $optionsJson)"
            val result = evaluateJavascript(bridge.webView, jsScript)

            // Workaround an issue where `evaluateJavascript` returns a string with surrounding quotation marks.
            return result?.removeSurrounding("\"")
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private suspend fun evaluateJavascript(webView: WebView, script: String): String? {
        return suspendCancellableCoroutine { continuation ->
            webView.evaluateJavascript(script) { result ->
                if (result != null && result != "null") {
                    continuation.resume(result)
                } else {
                    continuation.resume(null)
                }
            }
        }
    }

    companion object {
        var shared: ExtendedStreamPlugin? = null
            private set
    }
}
