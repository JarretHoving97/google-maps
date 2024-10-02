package com.whoisup.app.utils

import android.icu.text.RelativeDateTimeFormatter
import android.os.Build
import java.time.Duration
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.temporal.ChronoUnit
import java.util.Locale

fun formatRelative(date: ZonedDateTime, locale: Locale, ifTodayHideHours: Boolean = false): String {
    val zonedDate = date.withZoneSameInstant(ZoneId.systemDefault())

    val zonedNow = ZonedDateTime.now(ZoneId.systemDefault())

    val diffInCalendarDays = Duration.between(zonedNow.truncatedTo(ChronoUnit.DAYS), zonedDate.truncatedTo(ChronoUnit.DAYS)).toDays()

    if (diffInCalendarDays > -7) {
        // date is in the past week

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val isToday = diffInCalendarDays == 0L
            if (isToday) {
                if (ifTodayHideHours) {
                    // 'today'
                    val rtf = RelativeDateTimeFormatter.getInstance(locale)
                    return rtf.format(
                        RelativeDateTimeFormatter.Direction.THIS,
                        RelativeDateTimeFormatter.AbsoluteUnit.DAY
                    )
                }

                // '13:00' or '01:00 PM'
                return intlDateTimeFormat(date, DateTimeFormat.Hour2Digit_Minute2Digit, locale)
            }

            val isYesterday = diffInCalendarDays == -1L
            if (isYesterday) {
                // 'yesterday'
                val rtf = RelativeDateTimeFormatter.getInstance(locale)
                return rtf.format(
                    RelativeDateTimeFormatter.Direction.LAST,
                    RelativeDateTimeFormatter.AbsoluteUnit.DAY
                )
            }
        }

        // 'wednesday'
        return intlDateTimeFormat(date, DateTimeFormat.WeekdayLong, locale)
    }

    return intlDateTimeFormat(date, DateTimeFormat.YearNumeric_MonthShort_DayNumeric, locale)
}