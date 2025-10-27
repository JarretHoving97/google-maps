//
//  AppInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/10/2025.
//

import Foundation
import StreamChatSwiftUI

// contains information of the app. like an AppStoreID url, current app version etc.
public struct AppInfo {
    let appstoreId: String

    public init(appstoreId: String) {
        self.appstoreId = appstoreId
    }
}


// MARK: Dependency injection, currently still used by `StreamChatSwiftUI` which will be depracted in te future
private struct AppInfoKey: InjectionKey {
    static var currentValue: AppInfo?
}

extension InjectedValues {
    var appInfo: AppInfo? {
        get { Self[AppInfoKey.self] }
        set { Self[AppInfoKey.self] = newValue }
    }
}
