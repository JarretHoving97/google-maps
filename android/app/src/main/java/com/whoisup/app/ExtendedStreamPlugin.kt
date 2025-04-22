package com.whoisup.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.webkit.WebView
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import java.time.ZonedDateTime
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

    override fun handleOnNewIntent(data: Intent) {
        super.handleOnNewIntent(data)
        val bundle = data.extras
        if (bundle != null && bundle.containsKey("extended_stream_navigate_to")) {
            val jsObject = JSObject()
            if (bundle.containsKey("route")) {
                jsObject.put("route", bundle.getString("route"))
            }
            notifyListeners("navigateTo", jsObject, true)
        }
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

    var chatTrialUntil: ZonedDateTime? = null

    @PluginMethod
    fun setChatTrialUntil(call: PluginCall) {
        try {
            val chatTrialUntilString = call.getString("chatTrialUntil")
            chatTrialUntil = ZonedDateTime.parse(chatTrialUntilString)
        } catch (error: Exception) {
            // do nothing
        }

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

        fun notifyNavigateToListeners(context: Context, route: String, dismiss: Boolean) {
            if (shared != null) {
                // If the webview has been started,
                // notify the webview where to navigate
                shared?.let {
                    val jsObject = JSObject()
                    jsObject.put("route", route)
                    it.notifyListeners("navigateTo", jsObject)

                    if (dismiss) {
                        // finish()
                        // finishAffinity()
                        val intent = Intent(context, MainActivity::class.java)
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        intent.putExtra("EXIT", true)
                        context.startActivity(intent)
                    }
                }
            } else {
                // Otherwise, let's see what we can do
                if (dismiss) {
                    // If we mean to close the task anyways, we can bring up the `MainActivity`.
                    // We still lose the stack history before this then.
                    // But we'll live with it, because it shouldn't happen too much.
                    context.startActivity(Intent(context, MainActivity::class.java).apply {
                        putExtra("extended_stream_navigate_to", true)
                        putExtra("route", route)
                    })
                } else {
                    // We can't really do much here,
                    // because starting the `MainActivity` here would mess with our stack history.
                    // We could end up with something like this for example: `ChannelsActivity` -> `ChannelActivity(id: '1')` -> `MainActivity` -> `ChannelActivity(id: '2')`
                    // Then after navigating back from `ChannelActivity(id: '2')` it would start the `MainActivity` instead of `ChannelActivity(id: '1')`
                }
            }
        }

        fun notifyNavigateBackListeners(activity: Activity) {
            if (shared != null) {
                // If the webview has been started,
                // notify the webview that is has to navigate back (either in the background or not)
                shared?.notifyListeners("navigateBack", JSObject())
            } else if (activity.isTaskRoot) {
                // Otherwise, only if this is the task root (it was the first activity to be started),
                // start the MainActivity (webview).
                // Otherwise the app would be closed (which would be pretty much fine as well, but this feels better/possibly less bounce)
                activity.startActivity(Intent(activity, MainActivity::class.java))
            }
        }
    }
}
