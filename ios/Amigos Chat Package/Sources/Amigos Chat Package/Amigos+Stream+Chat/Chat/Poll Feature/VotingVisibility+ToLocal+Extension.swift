//
//  VotingVisibility+ToLocal+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation
import StreamChat

extension VotingVisibility: LocalMappable {

    public func toLocal() -> LocalVotingVisibility {
        return LocalVotingVisibility(rawValue: rawValue)
    }
}
