//
//  VideoFeedViewModel.swift
//  square_yards
//

import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var videos: [PropertyVideo] = []
    @Published private(set) var state: LoadingState = .idle
    @Published var selectedIndex = 0
    @Published var activeLeadVideo: PropertyVideo?
    @Published var isMuted = false

    private let service: VideoFeedServicing

    init(service: VideoFeedServicing = VideoFeedService()) {
        self.service = service
    }

    func loadVideosIfNeeded() async {
        guard state == .idle else { return }
        await loadVideos()
    }

    func retry() async {
        await loadVideos()
    }

    private func loadVideos() async {
        state = .loading

        do {
            videos = try await service.fetchVideos()
            ThumbnailPrefetcher.prefetch(urls: videos.map(\.thumbnailURL))
            state = .loaded
            selectedIndex = 0
            setSelectedIndex(0)
        } catch {
            state = .failed("Unable to load property videos right now.")
        }
    }

    func setSelectedIndex(_ index: Int) {
        guard videos.indices.contains(index) else { return }
        selectedIndex = index
    }

    func showLeadForm(for video: PropertyVideo) {
        activeLeadVideo = video
    }

    func dismissLeadForm() {
        activeLeadVideo = nil
    }

    var shouldPausePlayback: Bool {
        activeLeadVideo != nil
    }
}
