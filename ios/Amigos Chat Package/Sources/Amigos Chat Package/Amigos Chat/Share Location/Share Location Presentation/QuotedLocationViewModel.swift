//
//  QuotedLocationViewModel.swift
//  App
//
//  Created by Jarret on 23/12/2024.
//

import Foundation

class QuotedLocationViewModel {

    struct ShareLocationOption: Hashable {
        let name: String
        let url: URL?
    }

    var latitude: Double {
        locationAttachment.latitudeDouble
    }

    var longitude: Double {
        locationAttachment.longitudeDouble
    }

    let isSentByCurrentUser: Bool

    private let locationAttachment: LocationAttachment

    init(locationAttachment: LocationAttachment, isSentByCurrentUser: Bool) {
        self.locationAttachment = locationAttachment
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    var title: String {
        Localized.ShareLocation.usersLocationQuotedMessageViewTitle
    }

    func generateShareLocationUrls() -> [ShareLocationOption] {
        let lat = locationAttachment.latitudeDouble
        let lon = locationAttachment.longitudeDouble
        return ShareLocationURLService.generateShareLocationUrls(
            latitude: lat,
            longitude: lon
        ).map { ShareLocationOption(name: $0.name, url: $0.url) }
    }
}

// MARK: Translations
extension QuotedLocationViewModel {

    var dialogTitle: String {
        Localized.ShareLocation.chooseMapsDialogTitle
    }
}
