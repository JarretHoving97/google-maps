package com.whoisup.app.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color

private var Pale = Color(0xFF_F9F9F9)

private var Purple = Color(0xFF_7D27C9)

private var Orange = Color(0xFF_FA7B1E)

@Immutable
data class CustomColorScheme(
    val primary: Color,
    val secondary: Color,
    val tertiary: Color,
    val background: Color,
    val surface: Color,
    val surfaceHard: Color,
    val onPrimary: Color,
    val onSecondary: Color,
    val onTertiary: Color,
    val onBackground: Color,
    val onSurface: Color,
    val onSurfaceSoft: Color,
    val success: Color,
    val onSuccess: Color,
    val danger: Color,
    val onDanger: Color,
    val boxShadow: Color,
    val overlay: Color,
    val highlight: Color,
)

val DarkColorScheme =
    CustomColorScheme(
        primary = Purple,
        secondary = Orange,
        tertiary = Purple,
        background = Color.Black,
        surface = Color(0xFF222222),
        surfaceHard = Color.DarkGray,
        onPrimary = Color.White,
        onSecondary = Color.White,
        onTertiary = Color.White,
        onBackground = Color.White,
        onSurface = Color.White,
        onSurfaceSoft = Color.LightGray,
        success = Color(0xFF4EB788),
        onSuccess = Color.White,
        danger = Color(0xFFED254E),
        onDanger = Color.White,
        boxShadow = Color(0x14FFFFFF),
        overlay = Color(0x80444444),
        highlight = Color(0xFF2D1146),
    )

val LightColorScheme =
    CustomColorScheme(
        primary = Purple,
        secondary = Orange,
        tertiary = Purple,
        background = Color.White,
        surface = Pale,
        surfaceHard = Color(0xFFECEFF4),
        onPrimary = Color.White,
        onSecondary = Color.White,
        onTertiary = Color.White,
        onBackground = Color(0xFF333333),
        onSurface = Color(0xFF333333),
        onSurfaceSoft = Color.Gray,
        success = Color(0xFF4EB788),
        onSuccess = Color.White,
        danger = Color(0xFFED254E),
        onDanger = Color.White,
        boxShadow = Color(0x14000000),
        overlay = Color(0x80000000),
        highlight = Color(0xFFE5D4f3),
    )
