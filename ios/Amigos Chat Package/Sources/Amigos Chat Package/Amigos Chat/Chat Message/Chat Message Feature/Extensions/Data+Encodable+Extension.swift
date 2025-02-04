//
//  Date+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//
import Foundation

extension Data {

    func decoded<T: Decodable>(to type: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: self)
    }
    
}
