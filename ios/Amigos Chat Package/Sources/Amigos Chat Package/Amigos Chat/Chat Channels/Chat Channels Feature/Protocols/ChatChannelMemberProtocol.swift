//
//  ChatChannelMemberProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/08/2025.
//

import Foundation

protocol ChatChannelMemberProtocol {
    
    var id: String { get }

    var name: String? { get }

    var imageURL: URL? { get }
}
