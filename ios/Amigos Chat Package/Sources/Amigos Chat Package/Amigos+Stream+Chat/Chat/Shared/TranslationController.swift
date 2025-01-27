//
//  TranslationController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

public struct WebTranslationInfo {
    public let key: String
    public let namespace: String
    public let options: [String: Any]
}

public class TranslationController {

    public private(set) static var translate: ((WebTranslationInfo) async -> String?)?

    private init() {}

    public static func set(translate: @escaping ((WebTranslationInfo) async -> String?)) {
        self.translate = translate
    }
}
