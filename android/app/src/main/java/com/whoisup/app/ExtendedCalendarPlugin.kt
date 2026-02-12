package com.whoisup.app

import android.content.Intent
import android.provider.CalendarContract
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import java.time.Instant
import java.util.Calendar

fun PluginCall.getDateInMilli(name: String): Long? {
    val date = this.getString(name)
    if (date.isNullOrBlank()) {
        return null
    }

    return try {
        Instant.parse(date).toEpochMilli()
    } catch (_: Exception) {
        null
    }
}

@CapacitorPlugin(name = "ExtendedCalendar")
class ExtendedCalendarPlugin : Plugin() {
    @PluginMethod
    fun createEventWithPrompt(call: PluginCall) {
        val title = call.getString("title")
        val startDate = call.getDateInMilli("startDate")
        var endDate = call.getDateInMilli("endDate")
        val location = call.getString("location")
        val notes = call.getString("notes")

        if (title.isNullOrBlank()) {
            call.reject("Invalid or missing `title`")
            return
        }

        if (startDate == null) {
            call.reject("Invalid or missing `startDate`")
            return
        }

        // If there's no `endDate`, make sure it's set to two hours after the `startDate`
        endDate = endDate ?: Calendar.getInstance().apply {
            timeInMillis = startDate
            add(Calendar.HOUR, 2)
        }.timeInMillis

        addEvent(title, startDate, endDate, location, notes)

        call.resolve()
    }

    fun addEvent(title: String, startDate: Long, endDate: Long?, location: String?, notes: String?) {
        val intent = Intent(Intent.ACTION_INSERT).apply {
            data = CalendarContract.Events.CONTENT_URI
            putExtra(CalendarContract.Events.TITLE, title)
            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startDate)
            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endDate)
            putExtra(CalendarContract.Events.EVENT_LOCATION, location)
            putExtra(CalendarContract.Events.DESCRIPTION, notes)
        }

        if (intent.resolveActivity(context.packageManager) != null) {
            context.startActivity(intent)
        }
    }
}
