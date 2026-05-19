//
//  ThumbnailPrefetcher.swift
//  square_yards
//

import Foundation

enum ThumbnailPrefetcher {
    static func prefetch(urls: [URL]) {
        let session = URLSession.shared

        for url in urls {
            let request = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: 30
            )

            if URLCache.shared.cachedResponse(for: request) != nil {
                continue
            }

            let task = session.dataTask(with: request)
            task.priority = URLSessionTask.highPriority
            task.resume()
        }
    }
}
