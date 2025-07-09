//
//  UIColor+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/03/2025.
//

import UIKit.UIColor

extension UIColor {

    /// Initialize UIColor from a hex integer (e.g., `0xFF5733`).
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }

    // Initialize UIColor from a hex string (e.g., "#FF5733" or "FF5733")
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        formatted = formatted.replacingOccurrences(of: "#", with: "")

        guard formatted.count == 6, let hexValue = Int(formatted, radix: 16) else {
            return nil // Invalid hex string
        }

        self.init(hex: hexValue, alpha: alpha)
    }
}
