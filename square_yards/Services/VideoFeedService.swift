import Foundation

protocol VideoFeedServicing {
    func fetchVideos() async throws -> [PropertyVideo]
}

struct VideoFeedService: VideoFeedServicing {
    func fetchVideos() async throws -> [PropertyVideo] {
        guard let bundledURL = Bundle.main.url(forResource: "videos", withExtension: "json") else {
            throw VideoFeedServiceError.missingBundleResource
        }

        let data = try Data(contentsOf: bundledURL)
        return try JSONDecoder().decode(VideoFeedResponse.self, from: data).videos
    }
}

enum VideoFeedServiceError: LocalizedError {
    case missingBundleResource

    var errorDescription: String? {
        switch self {
        case .missingBundleResource:
            return "The bundled videos.json file could not be found."
        }
    }
}

private struct VideoFeedResponse: Decodable {
    let videos: [PropertyVideo]
}
