//
//  ReadReceiptsLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/01/2026.
//

import Foundation

typealias ReadReceiptsResult = (Result<[ReadReceiptCellViewModel], Error>) -> Void

protocol ReadReceiptsLoader {
    func load(completion: @escaping ReadReceiptsResult)
}
