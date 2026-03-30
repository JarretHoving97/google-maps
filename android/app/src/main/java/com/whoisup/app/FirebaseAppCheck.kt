package com.whoisup.app

import android.util.Log
import com.google.firebase.appcheck.AppCheckToken
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import kotlinx.coroutines.tasks.await

class FirebaseAppCheck() {
    companion object {
        private var cachedToken: AppCheckToken? = null

        private val firebaseAppCheckInstance: FirebaseAppCheck = FirebaseAppCheck.getInstance()

        init {
            if (BuildConfig.DEBUG) {
                firebaseAppCheckInstance
                    .installAppCheckProviderFactory(
                        DebugAppCheckProviderFactory.getInstance(),
                        true
                    )
            } else {
                firebaseAppCheckInstance
                    .installAppCheckProviderFactory(
                        PlayIntegrityAppCheckProviderFactory.getInstance(),
                        true
                    )
            }

            firebaseAppCheckInstance.addAppCheckListener { token: AppCheckToken? ->
                if (token !== null) {
                    cachedToken = token
                }
            }
        }

        suspend fun getToken(forceRefresh: Boolean): String? {
            if (!forceRefresh) {
                cachedToken?.let {
                    return@getToken it.token
                }
            }

            try {
                val result = firebaseAppCheckInstance.getAppCheckToken(forceRefresh).await()
                cachedToken = result
                return@getToken result.token
            } catch (exception: Exception) {
                Log.w("[Firebase] Get App Check token failed.", exception)
                return@getToken null
            }
        }
    }
}