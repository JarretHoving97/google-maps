//
//  CustomChannelActionViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/11/2025.
//

import Foundation
import SwiftUI
import UIKit.UIImage

@MainActor
class CustomChannelActionViewModel: ObservableObject {

    @Published
    var actions: [CustomChannelAction] = []

    init(actions: [CustomChannelAction]) {
        self.actions = actions
    }

    func imageIcon(for action: CustomChannelAction) -> UIImage {

        let iconName = action.iconName

        var result = UIImage(systemName: "chevron.right")!

        if let image = UIImage(systemName: iconName) {
            result = image
        }

        if let image = UIImage(named: iconName, in: .module, with: .none) {
            result =  image
        }

        return result.withRenderingMode(.alwaysTemplate)
    }
}
