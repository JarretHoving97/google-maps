package com.whoisup.app

import android.content.Intent
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import io.branch.referral.Branch
import io.branch.referral.util.BRANCH_STANDARD_EVENT
import io.branch.referral.util.BranchEvent
import io.branch.referral.util.CurrencyType

@CapacitorPlugin(name = "BranchDeepLinks")
class BranchDeepLinksPlugin : Plugin() {
    private val EVENT_INIT = "init"
    private val EVENT_INIT_ERROR = "initError"

    override fun handleOnNewIntent(intent: Intent?) {
        super.handleOnNewIntent(intent)
        activity.intent = intent
        if (intent != null && intent.hasExtra("branch_force_new_session") && intent.getBooleanExtra(
                "branch_force_new_session",
                false
            )
        ) {
            Branch.sessionBuilder(activity).withCallback(callback).reInit()
        }
    }

    override fun handleOnStart() {
        super.handleOnStart()
        Branch.sessionBuilder(activity).withCallback(callback).withData(activity.intent.data).init()
    }

    private val callback =
        Branch.BranchReferralInitListener { referringParams, error ->
            if (error == null) {
                val data = JSObject()
                data.put("referringParams", referringParams)
                notifyListeners(EVENT_INIT, data, true)
            } else {
                sendError(error.message)
            }
        }

    private fun sendError(error: String) {
        val data = JSObject()
        data.put("error", error)
        notifyListeners(EVENT_INIT_ERROR, data, true)
    }

    @PluginMethod
    fun sendBranchEvent(call: PluginCall) {
        if (!call.data.has("eventName")) {
            call.reject("Must provide an event name")
            return
        }

        val eventName = call.getString("eventName")
        val metaData = call.getObject("metaData", JSObject())

        val event: BranchEvent = try {
            val standardEvent = BRANCH_STANDARD_EVENT.valueOf(eventName!!)
            BranchEvent(standardEvent)
        } catch (e: IllegalArgumentException) {
            BranchEvent(eventName)
        }

        if (metaData == null) {
            call.resolve()
            return
        }

        var keys = metaData.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            if (key == "revenue") {
                event.setRevenue(metaData.getDouble("revenue"))
            } else if (key == "currency") {
                val currencyString = metaData.getString("currency")
                val currency = CurrencyType.getValue(currencyString)
                if (currency != null) {
                    event.setCurrency(currency)
                }
            } else if (key == "transactionID") {
                event.setTransactionID(metaData.getString("transactionID"))
            } else if (key == "coupon") {
                event.setCoupon(metaData.getString("coupon"))
            } else if (key == "shipping") {
                event.setShipping(metaData.getDouble("shipping"))
            } else if (key == "tax") {
                event.setTax(metaData.getDouble("tax"))
            } else if (key == "affiliation") {
                event.setAffiliation(metaData.getString("affiliation"))
            } else if (key == "description") {
                event.setDescription(metaData.getString("description"))
            } else if (key == "searchQuery") {
                event.setSearchQuery(metaData.getString("searchQuery"))
            } else if (key == "customerEventAlias") {
                event.setCustomerEventAlias(metaData.getString("customerEventAlias"))
            } else if (key == "customData") {
                val customData = metaData.getJSObject("customData")

                if (customData != null) {
                    keys = customData.keys()
                    while (keys.hasNext()) {
                        val keyValue = keys.next()
                        event.addCustomDataProperty(keyValue, customData.getString(keyValue))
                    }
                }
            }
        }

        event.logEvent(activity)

        call.resolve()
    }
}
