//
//  ImageURLExamples.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import Foundation

enum ImageURLExamples {

    static let portraitImageUrl = URL(string: "https://assets-dev.amigosapp.nl/placeholder/1024x1024.webp")!

    static let landscapeImageUrl = URL(string: "https://assets-dev.amigosapp.nl/placeholder/1792x1024.webp")!

    enum Interests {
        static let coffeeURL = URL(string: "https://assets.amigosapp.nl/icon/coffee-7c352dbf-1ccc-4615-87bc-4e5fde634412.svg")!
    }

    enum Community {
        static let coverURL = URL(string: "https://amigos-profilepictures-dev.s3.eu-central-1.amazonaws.com/public/covers/715x288/06eb9927-a080-4b68-8bfa-998eb0fa9d77.jpg")!
    }
}
