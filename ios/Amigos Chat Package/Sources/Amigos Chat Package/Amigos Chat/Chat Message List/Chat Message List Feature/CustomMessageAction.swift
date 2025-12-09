//
//  CustomMessageAction.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/11/2025.
//

import Foundation

public struct CustomMessageAction: Identifiable, Equatable {
    public var id: String
    public let title: String
    public let iconName: String
    public let action: () -> Void
    public let confirmationPopup: CustomConfirmationInfo?
    public let isDestructive: Bool

    public static func == (lhs: CustomMessageAction, rhs: CustomMessageAction) -> Bool {
        lhs.id == rhs.id
    }
}
