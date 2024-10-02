package com.whoisup.app

import android.content.Context
import androidx.appcompat.app.AppCompatActivity

class BaseAppCompatActivity : AppCompatActivity() {
    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(withCustomLocale(newBase))
    }
}