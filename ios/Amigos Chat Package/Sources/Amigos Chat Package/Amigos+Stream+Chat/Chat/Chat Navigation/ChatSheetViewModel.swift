//
//  ChatSheetViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/02/2026.
//

import SwiftUI

@MainActor
public class ChatSheetViewModel: ObservableObject {

    enum Route: String, Identifiable {

        var id: String {
            self.rawValue
        }

        case iceBreakers
    }

   @Published var route: Route?

    func present(_ route: Route) {
        self.route = route
    }
}
