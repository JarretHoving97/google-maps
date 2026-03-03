//
//  MessageSuggestionTemplates.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/02/2026.
//

import Amigos_Chat_Package
import Foundation

var participantTemplates: [IceBreakerParticipantSuggestionCategory: [String]] {
    return [
        .sixDays: [
            "message suggestion participant 1",
            "message suggestion participant 2",
            "message suggestion participant 3",
            "message suggestion participant 4"
        ]
    ]
}

var hostTemplates: [IceBreakerHostSuggestionCategory: [String]] {
   return [ .fiveDays: [
        "message suggestion host 1",
        "message suggestion host 2",
        "message suggestion host 3",
        "message suggestion host 4"
        ]
    ]
}
