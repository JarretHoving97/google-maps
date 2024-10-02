package com.whoisup.app.stream.extensions

import io.getstream.chat.android.models.Member

enum class AmiParticipantRole {
    Participant,
    Organizer,
    PseudoOrganizer
}

val Member.amiParticipantRole : AmiParticipantRole
    get() = when (this.channelRole) {
        "organizer" -> AmiParticipantRole.Organizer
        "co-organizer" -> AmiParticipantRole.PseudoOrganizer
        else -> AmiParticipantRole.Participant
    }