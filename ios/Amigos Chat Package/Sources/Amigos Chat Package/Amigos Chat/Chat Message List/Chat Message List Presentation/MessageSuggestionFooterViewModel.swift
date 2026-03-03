//
//  MessageSuggestionFooterViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/02/2026.
//

import SwiftUI

class MessageSuggestionFooterViewModel: ObservableObject {

    @Published var hostMessageSuggestionsViewModel: ChatSuggestionsViewModel

    let showMessageSuggestions: Bool
    let showsIceBreakerButton: Bool

    init(
        hostMessageSuggestionsViewModel: ChatSuggestionsViewModel,
        showMessageSuggestions: Bool,
        showsIceBreakerButton: Bool
    ) {
        self.hostMessageSuggestionsViewModel = hostMessageSuggestionsViewModel
        self.showMessageSuggestions = showMessageSuggestions
        self.showsIceBreakerButton = showsIceBreakerButton
    }
}
