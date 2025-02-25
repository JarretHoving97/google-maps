//
//  CustomShareLocationMessageViewModel.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//
import Foundation
import MobileCoreServices
import SwiftUI

public class CustomShareLocationMessageViewModel {

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

    private let user: LocalUser

    private let locationAttachment: LocationAttachment

    public init(location: LocationAttachment, user: LocalUser) {
        self.locationAttachment = location
        self.user = user
    }
}

// MARK: Translations
extension CustomShareLocationMessageViewModel {

    var dialogTitle: String {
        Localized.ShareLocation.chooseMapsDialogTitle
    }

    var authorLocationLabel: String {
        Localized.ShareLocation.authorsLocationLabel(author: user.name)
    }
}
