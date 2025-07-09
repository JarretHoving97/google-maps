//
//  CodableFileAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

struct CodableFileAttachment: Codable {

    func toLocal() -> FileAttachment {
        return FileAttachment()
    }
}
