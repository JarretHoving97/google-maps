//
//  PollDateIndicatorView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/09/2025.
//

import SwiftUI

struct PollDateIndicatorView: View {

    let date: Date

    var formattedDate: String {
        formatRelative(date: date, locale: .autoupdatingCurrent)
    }

    var body: some View {
        Text(formattedDate)
            .font(.caption2)
            .foregroundColor(Color(.grey))
    }
}
