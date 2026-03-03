//
//  IceBreakerViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2026.
//

import Foundation

@MainActor
class IceBreakerViewModel: ObservableObject {

    @Published var selectedIndex: Int = 0

    @Published var selectedSuggestion: String?

    @Published var messageSuggestions = [String]()

    let activityDate: Date?

    let messageSuggestionsResolver: any MessageSuggestionsResolver

    var selectedMessage: String? {
        guard messageSuggestions.indices.contains(selectedIndex) else { return nil }
        return messageSuggestions[selectedIndex]
    }

    init(
        activityDate: Date?,
        messageSuggestionsResolver: any MessageSuggestionsResolver
    ) {
        self.activityDate = activityDate
        self.messageSuggestionsResolver = messageSuggestionsResolver
        load()
    }

    private func load() {
        if let activityDate {
            self.messageSuggestions = messageSuggestionsResolver.resolve(for: activityDate)
        }
    }

    func select(_ suggestion: String) {
        self.selectedSuggestion = suggestion
    }
}

// MARK: Translations
extension IceBreakerViewModel {

    var navTitle: String {
        Localized.IceBreakers.navigationTitle
    }

    var description: String {
        Localized.IceBreakers.description
    }

    var buttonTitle: String {
        Localized.IceBreakers.buttonTitleSelect
    }

    static var templates: [String] {
        [
            Localized.IceBreakers.favoriteIntroDrink,
            Localized.IceBreakers.dilemmaAskerOrAnswerer,
            Localized.IceBreakers.dilemmaNeverAloneOrAlwaysAlone,
            Localized.IceBreakers.dilemmaPlannedOrSpontaneous,
            Localized.IceBreakers.twoTruthsOneLie
        ]
    }
}
