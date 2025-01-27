//
//  AttachmentsKey.swift
//  App
//
//  Created by Jarret on 09/12/2024.
//

import Foundation
import SwiftUI

struct AttachmentControllerKey: EnvironmentKey {
    static var defaultValue: AttachmentEnvironmentController = AttachmentEnvironmentController()
}

extension EnvironmentValues {

    var attachmentController: AttachmentEnvironmentController {
        get { self[AttachmentControllerKey.self] }
        set { self[AttachmentControllerKey.self] = newValue }
    }
}
