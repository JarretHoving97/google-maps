package com.whoisup.app

import android.content.Context
import android.content.res.Configuration
import androidx.activity.ComponentActivity

fun withCustomLocale(newBase: Context?): Context? {
    ExtendedStreamPlugin.shared?.locale?.let { locale ->
        // Set a custom Locale as follows: https://stackoverflow.com/a/61643167
        // Locale.setDefault(locale) // @TODO: this line seems to be unnecessary
        val config = Configuration()
        config.setLocale(locale)

        // Another strategy:
        // super.attachBaseContext(newBase)
        // applyOverrideConfiguration(config)

        return newBase?.createConfigurationContext(config)
    }

    return newBase
}

open class BaseComponentActivity : ComponentActivity() {
    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(withCustomLocale(newBase))
    }
}