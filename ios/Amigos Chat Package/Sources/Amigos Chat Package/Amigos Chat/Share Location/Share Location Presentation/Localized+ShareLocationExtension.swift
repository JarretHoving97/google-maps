//
//  Localized.swift
//  App
//
//  Created by Jarret on 03/12/2024.
//

import Foundation

extension Localized {

    enum ShareLocation {

        static var table: String { "ShareLocation" }

        static var title: String {
            NSLocalizedString(
                "share_location_toolbar_title",
                tableName: table,
                bundle: bundle,
                comment: "Navigation title share location view"
            )
        }

        static var chooseMapsDialogTitle: String {
            NSLocalizedString(
                "share_location_choose_maps_dialog_title",
                tableName: table,
                bundle: bundle,
                comment: "Dialog title for opening users location in maps"
            )
        }

        static func authorsLocationLabel(author: String) -> String {
            NSLocalizedString(
                "share_location_users_location_label",
                tableName: table,
                bundle: bundle,
                comment: "Users location label from chat"
            )
            .replacingOccurrences(of: "{USER_NAME}", with: author)
        }

        static var authorsLocationlabel: String {
            NSLocalizedString(
                "share_location_users_location_label",
                tableName: table,
                bundle: bundle,
                comment: "Dialog title for opening users location in maps"
            )
        }

        static var openAppleMapsLabel: String {
            NSLocalizedString(
                "share_location_choose_maps_apple_title",
                tableName: table,
                bundle: bundle,
                comment: "Apple maps option title for opening location dialog"
            )
        }

        static var openGoogleMapsLabel: String {
            NSLocalizedString(
                "share_location_choose_maps_google_title",
                tableName: table,
                bundle: bundle,
                comment: "Google Maps option title for opening location dialog"
            )
        }

        static func usersLocationPreviewLabel(author: String) -> String {
            NSLocalizedString(
                "share_location_users_location_preview_label",
                tableName: table,
                bundle: bundle,
                comment: "share location label from preview view before sending location to chat."
            )
            .replacingOccurrences(of: "{USER_NAME}", with: author)
        }

        static var shareYourLocationLabel: String {
            NSLocalizedString(
                "share_location_share_your_location_button_title",
                tableName: table,
                bundle: bundle,
                comment: "Share location button title when location is available"
            )
        }

        static var grantLocationAccessTitle: String {
            NSLocalizedString(
                "share_location_grant_permission_label",
                tableName: table,
                bundle: bundle,
                comment: "Share location button title when location is not available"
            )
        }

        static func accuracyInMetersSubtitle(meters: String) -> String {
            NSLocalizedString(
                "share_location_users_location_accuracy_label",
                tableName: table,
                bundle: bundle,
                comment: "Accuracy of users location in meters"
            )
            .replacingOccurrences(of: "{METERS_COUNT}", with: meters)
        }

        static var accuracyUnknownSubtitle: String {
            NSLocalizedString(
                "share_location_users_location_accuracy_unknown_label",
                tableName: table,
                bundle: bundle,
                comment: "subtitle of users location when there is no accuracy information"
            )
        }

        static var enableLocationsPopupTitle: String {
            NSLocalizedString(
                "share_location_permissions_not_determed_dialog_title",
                tableName: table,
                bundle: bundle,
                comment: "title for a pop-up with information why we need location permissions"
            )
        }

        static var goToSettingsPopupButtonTitle: String {
            NSLocalizedString(
                "share_location_permissions_not_determed_dialog_settings_button_title",
                tableName: table,
                bundle: bundle,
                comment: "button title for the location permissions pop-up"
            )
        }

        static var enablePreciseLocationButtonTitle: String {
            NSLocalizedString(
                "share_location_ask_precise_permission_button_title",
                tableName: table,
                bundle: bundle,
                comment: "Button that asks the user to enable precisie location."
            )
        }

        static var usersLocationQuotedMessageViewTitle: String {
            NSLocalizedString(
                "share_location_quoted_message_view_title",
                tableName: table,
                bundle: bundle,
                comment: "Location title for when a user is responding to a location"
            )
        }
    }
}
