package com.whoisup.app.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.whoisup.app.R

@Immutable
data class CustomTypography(
    val poppinsFamily: FontFamily =
        FontFamily(
            Font(R.font.poppins_light, FontWeight.Light),
            Font(R.font.poppins_regular, FontWeight.Normal),
            Font(R.font.poppins_medium, FontWeight.Medium),
            Font(R.font.poppins_semibold, FontWeight.SemiBold),
            Font(R.font.poppins_bold, FontWeight.Bold),
            Font(R.font.poppins_extrabold, FontWeight.ExtraBold),
        ),
    val paragraph: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 15.sp,
            fontWeight = FontWeight.W400,
            lineHeight = 22.sp
        ),
    val subhead: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 14.sp,
            fontWeight = FontWeight.W500,
            lineHeight = 21.sp
        ),
    val captionSmall: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 11.sp,
            fontWeight = FontWeight.W500,
            lineHeight = 16.sp
        ),
    val caption: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 13.sp,
            fontWeight = FontWeight.W400,
            lineHeight = 20.sp
        ),
    val headingExtraLarge: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 28.sp,
            fontWeight = FontWeight.W700,
            lineHeight = 42.sp
        ),
    val headingLarge: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 20.sp,
            fontWeight = FontWeight.W600,
            lineHeight = 30.sp
        ),
    val headingMedium: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 18.sp,
            fontWeight = FontWeight.W600,
            lineHeight = 27.sp
        ),
    val heading: TextStyle =
        TextStyle(
            color = Color.White,
            fontFamily = poppinsFamily,
            fontSize = 15.sp,
            fontWeight = FontWeight.W600,
            lineHeight = 22.sp
        )
)
