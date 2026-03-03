//
//  Localization+IceBreakers+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/02/2026.
//

import Foundation

extension Localized {

    enum IceBreakers {

        static var table: String { "IceBreakers" }

        static var navigationTitle: String {
            localized("icebreakers_navigation_title", table: table)
        }

        static var description: String {
            localized("icebreakers_view_description", table: table)
        }

        static var buttonTitleSelect: String {
            localized("icebreakers_buttont_title_select", table: table)
        }

        // MARK: - 5 day window
        static var favoriteIntroDrink: String {
            localized("icebreakers_suggestion_favorite_intro_drink", table: table)
        }

        static var dilemmaAskerOrAnswerer: String {
            localized("icebreakers_suggestion_dilemma_asker_or_answerer", table: table)
        }

        static var dilemmaNeverAloneOrAlwaysAlone: String {
            localized("icebreakers_suggestion_dilemma_never_alone_or_always_alone", table: table)
        }

        static var dilemmaPlannedOrSpontaneous: String {
            localized("icebreakers_suggestion_dilemma_planned_or_spontaneous", table: table)
        }

        static var twoTruthsOneLie: String {
            localized("icebreakers_suggestion_two_truths_one_lie", table: table)
        }

    }
}
