package com.whoisup.app.stream.extensions

import io.getstream.chat.android.models.Member

enum class AmiParticipantRole {
    Participant,
    Organizer,
    PseudoOrganizer,
    CommunityOrganizer,
    CommunityPseudoOrganizer
}

val Member.amiParticipantRole : AmiParticipantRole
    get() = when (this.channelRole) {
        "organizer" -> AmiParticipantRole.Organizer
        "co-organizer" -> AmiParticipantRole.PseudoOrganizer
        "community_organizer" -> AmiParticipantRole.CommunityOrganizer
        "community_co-organizer" -> AmiParticipantRole.CommunityPseudoOrganizer
        else -> AmiParticipantRole.Participant
    }