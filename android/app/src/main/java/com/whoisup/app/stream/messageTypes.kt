package com.whoisup.app.stream

enum class MessageTranslationKeyEnum(val value: String) {
    AttendanceReminder("attendance_reminder"),
    GroupChatCreated("group_chat_created"),
    GroupChatJoined("group_chat_joined")
}

enum class MessageLayoutKeyEnum(val value: String) {
    Anonymous("anonymous"),
    Onboarding("onboarding"),
    HowToHost("how_to_host"),
    HowToJoin("how_to_join")
}