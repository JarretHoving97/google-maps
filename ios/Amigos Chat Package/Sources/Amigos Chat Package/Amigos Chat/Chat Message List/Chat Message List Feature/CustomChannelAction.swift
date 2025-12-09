//
//  CustomChannelAction.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/11/2025.
//

import Foundation

struct CustomChannelAction: Identifiable {

    let id = UUID()
    let title: String
    let action: () -> Void
    let confirmationInfo: CustomConfirmationInfo?
    let iconName: String
    let isDestructive: Bool

    init(
        title: String,
        action: @escaping () -> Void,
        confirmationInfo: CustomConfirmationInfo? = nil,
        imageName: String = "",
        isDestructive: Bool = false
    ) {
        self.title = title
        self.action = action
        self.confirmationInfo = confirmationInfo
        self.iconName = imageName
        self.isDestructive = isDestructive
    }
}

public struct CustomConfirmationInfo {
    let title: String
    let buttonTitle: String
    let message: String

    init(
        title: String = "",
        buttonTitle: String = "",
        message: String = ""
    ) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.message = message
    }
}
