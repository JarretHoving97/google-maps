package com.whoisup.app

// Object to hold build configuration values based on the environment
object BuildConfiguration {
    val streamApiKey: String
        get() = "aetbj83fpknp"

    val streamAuthTokenApiUrl: String
        get() = "https://api.app.amigosapp.nl/auth/stream/token"

    val amigosApiUrl: String
        get() = "https://api.app.amigosapp.nl"
}
