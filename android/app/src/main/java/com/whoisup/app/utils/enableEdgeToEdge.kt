package com.whoisup.app.utils

import android.graphics.Color
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge

fun ComponentActivity.enableEdgeToEdgeCustom() {
    // @TODO: Whenever we're going to support dynamic dark mode
    // change the style to reflect that
    enableEdgeToEdge(
        statusBarStyle = SystemBarStyle.light(Color.TRANSPARENT, Color.BLACK),
        navigationBarStyle = SystemBarStyle.light(Color.TRANSPARENT, Color.BLACK)
    )
}