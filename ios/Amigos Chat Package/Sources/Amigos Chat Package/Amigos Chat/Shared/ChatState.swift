//
//  ChatState.swift
//  Amigos Chat Package
//
//  Created by Jarret on 28/11/2025.
//

import SwiftUI

public class ChatFeatureState: ObservableObject {

    public enum Screen {
        case none
        case channelsList
        case channel(channelId: String)
    }

    public static let shared = ChatFeatureState()

    @Published public private(set) var currentScreen: Screen = .none

    private init() {}

    public func set(screen: Screen) {
        self.currentScreen = screen
    }
}
