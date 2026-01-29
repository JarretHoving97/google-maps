//
//  CapPluginCall+Helper+Extension.swift
//  App
//
//  Created by Jarret on 09/01/2026.
//

import Foundation
import Capacitor

extension CAPPluginCall {

    enum ParseError: Swift.Error, LocalizedError {
        case missingField(field: String)
        case invalidISODate(field: String, value: String)

        var errorDescription: String? {
            switch self {
            case .missingField(field: let key):
                return "Missing required field '\(key)'."

            case .invalidISODate(let field, let value):
                return "Invalid ISO date for '\(field)': \(value)"
            }
        }
    }

    func requireString(_ key: String) throws -> String {
        guard let value = self.getString(key) else { throw ParseError.missingField(field: key) }
        return value
    }

    func requireISO8601Date(
        _ key: String,
        with formatter: ISO8601DateFormatter = ISO8601DateFormatter(),
        options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds]
    ) throws -> Date {
        guard let date = getISO8601Date(key, with: formatter, options: options) else {
            let raw = try requireString(key)
            throw ParseError.invalidISODate(field: key, value: raw)
        }
        return date
    }

    func getISO8601Date(
        _ key: String,
        with formatter: ISO8601DateFormatter = ISO8601DateFormatter(),
        options: ISO8601DateFormatter.Options = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
    ) -> Date? {
        guard let raw = getString(key) else { return nil }
        formatter.formatOptions = options
        return formatter.date(from: raw)
    }
}
