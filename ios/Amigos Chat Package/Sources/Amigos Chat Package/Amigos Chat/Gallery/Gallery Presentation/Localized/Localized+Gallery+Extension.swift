//
//  Localized+Gallery+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 17/02/2025.
//

import Foundation

extension Localized {

    enum AttachmentType {
        case video
        case photo
    }

    enum Gallery {

        static var table: String { "Gallery" }

        static var selectTitle: String {
             NSLocalizedString(
                 "gallery_select_attachments",
                 tableName: table,
                 bundle: bundle,
                 comment: "UIMenu picker option to enable select attachments"
             )
         }

        static func attachmentsSelectedLabel(attachments: [AttachmentType]) -> String {
            let formatString : String = NSLocalizedString(
                "selected_media_attachments_count",
                tableName: table,
                bundle: bundle,
                comment: "Plurals localization for media attachments count"
            )
            let resultString: String = String.localizedStringWithFormat(formatString, attachments.count)

            return resultString
        }

        static var doneTrailingButtonLabel: String {
            NSLocalizedString(
                "gallery_select_trailing_button_title",
                tableName: table,
                bundle: bundle,
                comment: "Trailing button label on the gallery screen when selecting mode is enabled"
            )
        }

        static var selectAllButtonLabel: String {
            NSLocalizedString(
                "gallery_select_every_attachment",
                tableName: table,
                bundle: bundle,
                comment: "Button label on the gallery screen to select all items"
            )
        }

        static var deselectAllButtonLabel: String {
            NSLocalizedString(
                "gallery_deselect_every_attachment",
                tableName: table,
                bundle: bundle,
                comment: "Button label on the gallery screen to deselect all items"
            )
        }

        static private func key(for attachments: [AttachmentType]) -> String {
            let hasPhoto = attachments.contains(.photo)
            let hasVideo = attachments.contains(.video)

            switch attachments.count {
            case 0:
                return "gallery_items_selected"
            case 1:
                return hasPhoto ? "gallery_photo_selected" : "gallery_video_selected"
            default:
                if hasPhoto && hasVideo {
                    return "gallery_items_selected"
                }
                return hasPhoto ? "gallery_photos_selected" : "gallery_videos_selected"
            }
        }
    }
}
