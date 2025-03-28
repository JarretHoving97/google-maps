//
//  UserData.swift
//  Amigos Chat Package
//
//  Created by Ilon on 27/03/2025.
//

public struct UserData: Equatable {
    let id: String
    let imageUrl: String
    let name: String

    public init(id: String, imageUrl: String, name: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
    }
}
