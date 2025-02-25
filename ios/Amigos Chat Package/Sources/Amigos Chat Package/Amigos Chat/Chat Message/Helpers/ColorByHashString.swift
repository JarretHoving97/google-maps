//
//  ColorByHashString.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/02/2025.
//

import SwiftUI


func colorByString(_ str: String) -> Color {
    let colors: [Color] = [
        Color(red: 0xE5/255, green: 0x1C/255, blue: 0x23/255),
        Color(red: 0xE9/255, green: 0x1E/255, blue: 0x63/255),
        Color(red: 0x3F/255, green: 0x51/255, blue: 0xB5/255),
        Color(red: 0x56/255, green: 0x77/255, blue: 0xFC/255),
        Color(red: 0x03/255, green: 0xA9/255, blue: 0xF4/255),
        Color(red: 0x00/255, green: 0xBC/255, blue: 0xD4/255),
        Color(red: 0x00/255, green: 0x96/255, blue: 0x88/255),
        Color(red: 0x25/255, green: 0x9B/255, blue: 0x24/255),
        Color(red: 0x8B/255, green: 0xC3/255, blue: 0x4A/255),
        Color(red: 0xAF/255, green: 0xB4/255, blue: 0x2B/255),
        Color(red: 0xFF/255, green: 0x98/255, blue: 0x00/255),
        Color(red: 0xFF/255, green: 0x57/255, blue: 0x22/255),
        Color(red: 0x79/255, green: 0x55/255, blue: 0x48/255),
        Color(red: 0x60/255, green: 0x7D/255, blue: 0x8B/255)
    ]

    var hash = 0
    if str.isEmpty {
        return colors[0]
    }

    for char in str {
        hash = Int(char.asciiValue ?? 0) &+ ((hash << 5) &- hash)
        hash = hash & hash
    }

    hash = ((hash % colors.count) + colors.count) % colors.count
    return colors[hash]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
