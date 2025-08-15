import StreamChat

extension MemberRole {

    // community roles
    static let communityParticipant = Self(rawValue: "community_participant")
    static let communityCoOrganizer = Self(rawValue: "community_co-organizer")
    static let communityOrganizer = Self(rawValue: "community_organizer")

    // activity roles
    static let organizer = Self(rawValue: "organizer")
    static let coOrganizer = Self(rawValue: "co-organizer")
    static let channelMember = Self(rawValue: "member")
}
