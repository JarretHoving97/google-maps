//
//  CodableLocationAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/02/2025.
//

import Foundation

struct CodableLocationAttachment: Codable {
    let latitudeDouble: Double
    let longitudeDouble: Double
}

extension CodableLocationAttachment {
    func toLocal() -> LocationAttachment {
        LocationAttachment(
            id: UUID(),
            latitudeDouble: latitudeDouble,
            longitudeDouble: longitudeDouble
        )
    }
}
