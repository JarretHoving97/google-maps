package com.whoisup.app

import android.app.Application
import com.whoisup.app.helpers.getUserId
import io.branch.referral.Branch

class CustomApplicationClass : Application() {
    override fun onCreate() {
        super.onCreate()

        Stream.setup(this)

        val userId = getUserId(this)

        if (userId != null) {
            Stream.logIn(
                context = this,
                userId = userId,
                name = null,
                avatarUrl = null
            )
        }

        // Branch object initialization
        Branch.getAutoInstance(this)
    }
}
