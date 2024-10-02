package com.whoisup.app.stream.extensions

import io.getstream.chat.android.models.User

val User.isSupportTeamMember : Boolean
    get() = this.role == "moderator"