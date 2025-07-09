//
//  Message+LocalState+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/03/2025.
//

import Foundation

extension Message {

    public enum LocalState: String {
        /// The message is waiting to be synced.
        case pendingSync
        /// The message is currently being synced
        case syncing
        /// Syncing of the message failed after multiple of tries. The system is not trying to sync this message anymore.
        case syncingFailed

        /// The message is waiting to be sent.
        case pendingSend
        /// The message is currently being sent to the servers.
        case sending
        /// Sending of the message failed after multiple of tries. The system is not trying to send this message anymore.
        case sendingFailed

        /// The message is waiting to be deleted.
        case deleting
        /// Deleting of the message failed after multiple of tries. The system is not trying to delete this message anymore.
        case deletingFailed

        /// If the message is available only locally. The message is not on the server.
        var isLocalOnly: Bool {
            self == .pendingSend || self == .sendingFailed || self == .sending
        }
    }
}
