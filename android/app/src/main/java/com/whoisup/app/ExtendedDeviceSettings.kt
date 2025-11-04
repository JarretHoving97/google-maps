package com.whoisup.app

import android.content.Context
import android.text.format.DateFormat
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.whoisup.app.utils.getLocale
import java.time.chrono.IsoChronology
import java.time.format.DateTimeFormatterBuilder
import java.time.format.FormatStyle

enum class HourCycle(val value: String) {
    h11("h11"),
    h12("h12"),
    h23("h23"),
    h24("h24")
}

@CapacitorPlugin(name = "ExtendedDeviceSettings")
class ExtendedDeviceSettingsPlugin : Plugin() {
    @PluginMethod
    fun getHourCycle(call: PluginCall) {
        val hourCycle = getHourCycle(context)
        val ret = JSObject()
        ret.put("hourCycle", hourCycle.value)
        call.resolve(ret)
    }

    companion object {
        @JvmStatic
        fun getHourCycle(context: Context): HourCycle {
            val locale = getLocale(context)

            // Get the best matching localized time pattern for the provided locale.
            // This approach works better than, for example, `DateFormat.getBestDateTimePattern`,
            // because with `DateFormat.getBestDateTimePattern` you need to provide the pattern explicitly,
            // which then will _not_ necessarily get updated to the correct pattern for the provided locale.
            val timePattern =
                DateTimeFormatterBuilder.getLocalizedDateTimePattern(
                    null,
                    FormatStyle.SHORT, // it's important to use the .SHORT style here. Other styles might omit the "a.m./p.m." part in favor of a timezone for example (not sure why though)
                    IsoChronology.INSTANCE,
                    locale
                )

            val hourCycle = when {
                // Try to figure out which hour cycle this device uses by looking at the time pattern
                // This is following the official definition: https://unicode.org/reports/tr35/#UnicodeHourCycleIdentifier
                timePattern.contains("K") -> HourCycle.h11 // 12-hour, 0-11
                timePattern.contains("h") -> HourCycle.h12 // 12-hour, 1-12
                timePattern.contains("H") -> HourCycle.h23 // 24-hour, 0-23
                timePattern.contains("k") -> HourCycle.h24 // 24-hour, 1-24
                else -> {
                    // Fallback to only differentiating between 24 hour and 12 hour clocks
                    if (DateFormat.is24HourFormat(context)) {
                        HourCycle.h23 // most common 24 hour clock
                    } else {
                        HourCycle.h12 // most common 12 hour clock
                    }
                }
            }

            return hourCycle
        }
    }
}