//
//  CustomAppCheckProviderFactory.swift
//  App
//
//  Created by Jarret on 23/03/2026.
//


import Foundation
import FirebaseCore
import FirebaseAppCheck

enum FirebaseAppCheckError: Error {
    case firebaseError(Error)
    case noTokenFound
}

public class FirebaseAppCheck {

    static let shared = FirebaseAppCheck()

    private var cachedToken: String?

    init() {
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppCheckTokenChanged), name: .AppCheckTokenDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AppCheckTokenDidChange, object: nil)
    }

    public func getToken(forceRefresh: Bool, completion: @escaping (Result<String, Error>) -> Void) {

        if let cachedToken, !forceRefresh {
            completion(.success(cachedToken))
            return
        }

        AppCheck.appCheck().token(forcingRefresh: forceRefresh, completion: { [weak self] result, error in
            if let error = error {
                completion(.failure(FirebaseAppCheckError.firebaseError(error)))
                return
            }

            guard let token = result?.token else {
                completion(.failure(FirebaseAppCheckError.noTokenFound))
                return
            }

            self?.cachedToken = token

            completion(.success(token))
        })
    }

    @objc func handleAppCheckTokenChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let token = userInfo[AppCheckTokenNotificationKey] as? String else { return }
        self.cachedToken = token
    }
}
