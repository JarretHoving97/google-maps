//
//  ChatContext.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

import Foundation

public protocol ChatContext {
    var token: String? { get }
    var apiKey: String? { get }
    var appGroupId: String { get }
}
