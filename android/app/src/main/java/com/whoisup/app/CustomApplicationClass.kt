package com.whoisup.app

import android.app.Application
import io.branch.referral.Branch

class CustomApplicationClass : Application() {
    override fun onCreate() {
        super.onCreate()

        // Branch object initialization
        Branch.getAutoInstance(this)
    }
}
