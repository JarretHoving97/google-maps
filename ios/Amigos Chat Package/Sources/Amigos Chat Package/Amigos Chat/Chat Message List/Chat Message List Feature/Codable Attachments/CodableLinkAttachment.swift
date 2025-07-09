//
//  CodableLinkAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

struct CodableLinkAttachment: Codable {
    let url: URL
}

extension CodableLinkAttachment {

    func toLocal() -> LinkAttachment {
        LinkAttachment(url: url)
    }
}
