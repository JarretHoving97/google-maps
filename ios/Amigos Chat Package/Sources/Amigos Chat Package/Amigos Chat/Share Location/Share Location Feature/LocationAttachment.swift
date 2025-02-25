//
//  LocationAttachment.swift
//  App
//
//  Created by Jarret Hoving on 25/11/2024.
//

import StreamChat
import Foundation

extension AttachmentType {
    static let location = Self(rawValue: "geolocation")
}

public struct LocationAttachmentPayload: AttachmentPayload {

    public static var type: AttachmentType = .location

    let latitudeDouble: Double
    let longitudeDouble: Double

    init(lat: Double, lon: Double) {
        self.latitudeDouble = lat
        self.longitudeDouble = lon
    }
}

extension LocationAttachmentPayload: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}
