package com.whoisup.app.utils

import android.text.format.DateFormat
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.chrono.IsoChronology
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.format.FormatStyle
import java.time.format.TextStyle
import java.util.Locale

enum class DateTimeFormat {
    WeekdayLong_MonthLong_DayNumeric,
    Hour2Digit_Minute2Digit,
    MonthShort_DayNumeric_Hour2Digit_Minute2Digit,
    YearNumeric_MonthShort_DayNumeric,
    MonthShort_DayNumeric,
    DayNumeric,
    WeekdayShort_YearNumeric_MonthShort_DayNumeric,
    WeekdayShort_MonthShort_DayNumeric,
    YearNumeric_MonthShort_Day2Digit,
    WeekdayLong,
}

// difference with JS Intl API: `mmm` will result in an abbreviation of the month ending on a `.`
// (dot). Whereas in JS Intl API the trailing dot is omitted.

fun intlDateTimeFormat(date: ZonedDateTime, format: DateTimeFormat, locale: Locale): String {
    val zonedDate = date.withZoneSameInstant(ZoneId.systemDefault())


    val pattern = when (format) {
        DateTimeFormat.WeekdayLong_MonthLong_DayNumeric -> {
            DateFormat.getBestDateTimePattern(locale, "EEEE, MMMM d")
        }
        DateTimeFormat.Hour2Digit_Minute2Digit -> {
            // difference with JS Intl API: this will result in numeric hour format in ES for example
            DateTimeFormatterBuilder.getLocalizedDateTimePattern(
                null,
                FormatStyle.SHORT,
                IsoChronology.INSTANCE,
                locale
            )
        }
        DateTimeFormat.MonthShort_DayNumeric_Hour2Digit_Minute2Digit -> {
            // difference with JS Intl API: this will result in numeric hour format in ES for example
            val timePattern =
                DateTimeFormatterBuilder.getLocalizedDateTimePattern(
                    null,
                    FormatStyle.SHORT,
                    IsoChronology.INSTANCE,
                    locale
                )

            DateFormat.getBestDateTimePattern(locale, "MMM d, $timePattern")
        }
        DateTimeFormat.YearNumeric_MonthShort_DayNumeric -> {
            DateFormat.getBestDateTimePattern(locale, "MMM d y")
        }
        DateTimeFormat.MonthShort_DayNumeric -> {
            DateFormat.getBestDateTimePattern(locale, "MMM d")
        }
        DateTimeFormat.DayNumeric -> {
            "d"
        }
        DateTimeFormat.WeekdayShort_YearNumeric_MonthShort_DayNumeric -> {
            DateFormat.getBestDateTimePattern(locale, "EEE, MMM d, y")
        }
        DateTimeFormat.WeekdayShort_MonthShort_DayNumeric -> {
            DateFormat.getBestDateTimePattern(locale, "EEE, MMM d")
        }
        DateTimeFormat.YearNumeric_MonthShort_Day2Digit -> {
            DateFormat.getBestDateTimePattern(locale, "MMM dd, y")
        }
        DateTimeFormat.WeekdayLong -> {
            return zonedDate.dayOfWeek.getDisplayName(TextStyle.FULL, locale)
        }
    }

    return zonedDate.format(DateTimeFormatter.ofPattern(pattern).withLocale(locale))
}

@Preview(showBackground = true)
@Composable
fun IntlDateTimeFormatPreview() {
    val date = ZonedDateTime.parse("2024-01-01T12:32:00.000Z")
    val locale = Locale("nl", "NL")

    val date01 = intlDateTimeFormat(date, DateTimeFormat.MonthShort_DayNumeric_Hour2Digit_Minute2Digit, locale)

    BasicText(
        text = date01
    )
}