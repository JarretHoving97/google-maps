//
//  String+UniqeID+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import Foundation

extension String {

    public static var uniqueID: String {
        return UUID().uuidString
    }
}
