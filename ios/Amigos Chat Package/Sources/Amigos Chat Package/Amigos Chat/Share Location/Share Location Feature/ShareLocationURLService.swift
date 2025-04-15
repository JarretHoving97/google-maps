//
//  ShareLocationURLService.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2025.
//

import Foundation

struct ShareLocationURLService {

    struct ShareLocationOption: Hashable {
        let name: String
        let url: URL?
    }

    static func generateShareLocationUrls(latitude: Double, longitude: Double) -> [ShareLocationOption] {
        return [
            ShareLocationOption(
                name: Localized.ShareLocation.openGoogleMapsLabel,
                url: URL(string: "https://www.google.com/maps?q=\(latitude),\(longitude)")
            ),
            ShareLocationOption(
                name: Localized.ShareLocation.openAppleMapsLabel,
                url: URL(string: "https://maps.apple.com/?q=\(latitude),\(longitude)")
            )
        ]
    }
}
