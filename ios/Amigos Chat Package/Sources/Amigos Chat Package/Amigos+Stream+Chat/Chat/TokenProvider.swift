// swiftlint:disable all
import Foundation


public protocol TokenProvider {
    typealias TokenLoadResult = ((Result<LocalToken, Error>) -> Void)
    func loadToken(completion: @escaping TokenLoadResult)
}

public struct LocalToken {
    let token: String

    public init(token: String) {
        self.token = token
    }
}
