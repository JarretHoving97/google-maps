package com.whoisup.app.helpers

import androidx.compose.ui.graphics.Color

fun getColorByHashingString(str: String): Color {
    val colors = listOf(
        Color(0xFFE51C23), Color(0xFFE91E63), // Color(0xFF9C27B0), Color(0xFF673AB7),
        Color(0xFF3F51B5), Color(0xFF5677FC), Color(0xFF03A9F4), Color(0xFF00BCD4),
        Color(0xFF009688), Color(0xFF259B24), Color(0xFF8BC34A), Color(0xFFAFB42B),
        Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFF795548), Color(0xFF607D8B)
    )

    var hash = 0
    if (str.isEmpty()) {
        return colors[0]
    }

    for (i in str.indices) {
        hash = str[i].code + ((hash shl 5) - hash)
        hash = hash and hash
    }

    hash = ((hash % colors.size) + colors.size) % colors.size
    return colors[hash]
}