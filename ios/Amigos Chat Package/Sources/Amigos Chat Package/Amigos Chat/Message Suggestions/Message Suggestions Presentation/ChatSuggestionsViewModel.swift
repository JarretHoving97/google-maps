//
//  ChatSuggestionsViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/02/2026.
//

import SwiftUI

@MainActor
public class ChatSuggestionsViewModel: ObservableObject {

    @Published var selectedSuggestion: String?

    @Published private(set) var suggestions: [String] = []

    @Published var isScrolling: Bool = false

    var actityDate: Date?

    private let messageSuggestionResolver: MessageSuggestionResolver

    public init(activityDate: Date?, resolver: MessageSuggestionResolver ) {
        self.actityDate = activityDate
        self.messageSuggestionResolver = resolver
    }

    func load() {
        guard let actityDate else { return }

        messageSuggestionResolver.templates = [
            .fourtyEightHours: suggestionsFourtyEightHours,
            .nineHours: suggestionsNineHours,
            .threeHours: suggestionThreeHours
        ]

        suggestions = messageSuggestionResolver.resolve(for: actityDate)
    }

    func selectSuggestion(_ text: String) {
        selectedSuggestion = text
    }
}

// MARK: translations

extension ChatSuggestionsViewModel {

    private var suggestionsFourtyEightHours: [String] {
        [
            Localized.MessageSuggestions.planCTA,
            Localized.MessageSuggestions.whenFull,
            Localized.MessageSuggestions.whereFull,
            Localized.MessageSuggestions.whenShort,
            Localized.MessageSuggestions.timeFull
        ]
    }

    private var suggestionsNineHours: [String] {
        [
            Localized.MessageSuggestions.funGroupAlready,
            Localized.MessageSuggestions.whoFirstTime,
            Localized.MessageSuggestions.excitedToMeet,
            Localized.MessageSuggestions.cantWaitShort,
            Localized.MessageSuggestions.firstTimeHosting
        ]
    }

    private var suggestionThreeHours: [String] {
        [
            Localized.MessageSuggestions.arrivalTenBefore,
            Localized.MessageSuggestions.whenArrival,
            Localized.MessageSuggestions.waitingOutside,
            Localized.MessageSuggestions.whereMeet,
            Localized.MessageSuggestions.delayedRunningLate
        ]
    }
}
