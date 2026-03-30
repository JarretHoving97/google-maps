package com.whoisup.app

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

@CapacitorPlugin(name = "ExtendedFirebase")
class ExtendedFirebasePlugin : Plugin() {
    @PluginMethod
    fun getAppCheckToken(call: PluginCall) {
        val forceRefresh = call.getBoolean("forceRefresh", false) ?: false

        CoroutineScope(Dispatchers.IO).launch {
            val token = FirebaseAppCheck.getToken(forceRefresh)
            val result = JSObject()
            result.put("token", token)
            call.resolve(result)
        }
    }
}