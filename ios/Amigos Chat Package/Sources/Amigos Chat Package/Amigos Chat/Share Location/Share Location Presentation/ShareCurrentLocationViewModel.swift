//
//  ShareCurrentLocationViewModel.swift
//  App
//
//  Created by Jarret on 02/12/2024.
//

import Foundation

struct ShareCurrentLocationViewModel: Equatable {
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
