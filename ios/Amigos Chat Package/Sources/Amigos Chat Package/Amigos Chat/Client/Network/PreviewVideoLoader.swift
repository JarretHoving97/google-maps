//
//  PreviewVideoLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import Foundation
import UIKit
import SwiftUI
import AVKit

/// A protocol the video preview uploader implementation must conform to.
public protocol PreviewVideoLoader: AnyObject {
    /// Loads a preview for the video at given URL.
    /// - Parameters:
    ///   - url: A video URL.
    ///   - completion: A completion that is called when a preview is loaded. Must be invoked on main queue.
    func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

public final class DefaultPreviewVideoLoader: PreviewVideoLoader {

    private let cache: Cache<URL, UIImage>

    public init(countLimit: Int = 50) {
        cache = .init(countLimit: countLimit)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let cached = cache[url] {
            return call(completion, with: .success(cached))
        }

        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let frameTime = CMTime(seconds: 0.1, preferredTimescale: 600)

        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.generateCGImagesAsynchronously(forTimes: [.init(time: frameTime)]) { [weak self] _, image, _, _, error in
            guard let self = self else { return }

            let result: Result<UIImage, Error>
            if let thumbnail = image {
                result = .success(.init(cgImage: thumbnail))
            } else if let error = error {
                result = .failure(error)
            } else {
                return
            }

            self.cache[url] = try? result.get()
            self.call(completion, with: result)
        }
    }

    private func call(_ completion: @escaping (Result<UIImage, Error>) -> Void, with result: Result<UIImage, Error>) {
        if Thread.current.isMainThread {
            completion(result)
        } else {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    @objc private func handleMemoryWarning(_ notification: NSNotification) {
        cache.removeAllObjects()
    }
}

final class Cache<Key: Hashable, Value> {
    private let wrapped: NSCache<WrappedKey, Entry>

    init(countLimit: Int = 0) {
        wrapped = .init()
        wrapped.countLimit = countLimit
    }

    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }

    func insert(_ value: Value, forKey key: Key) {
        wrapped.setObject(.init(value: value), forKey: .init(key))
    }

    func value(forKey key: Key) -> Value? {
        wrapped.object(forKey: .init(key))?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: .init(key))
    }

    func removeAllObjects() {
        wrapped.removeAllObjects()
    }
}

/// Cache object reused from stream
private extension Cache {

    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }

    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
