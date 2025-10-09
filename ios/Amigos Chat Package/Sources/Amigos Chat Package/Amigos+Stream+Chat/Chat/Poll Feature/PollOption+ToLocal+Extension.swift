//
//  PollOption+ToLocal+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation
import StreamChat

extension PollOption: LocalMappable {

    public func toLocal() -> LocalPollOption {
        LocalPollOption(
            id: id,
            text: text,
            latestVotes: latestVotes.toLocal()
        )
    }
}
