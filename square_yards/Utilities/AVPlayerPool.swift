import AVFoundation
import Foundation

@MainActor
final class AVPlayerPool: ObservableObject {
    private final class PlayerContainer {
        let player: AVPlayer
        private var hasPrimedPlayback = false
        private var endObserver: NSObjectProtocol?

        init(url: URL) {
            let item = AVPlayerItem(url: url)
            item.preferredForwardBufferDuration = 10
            item.canUseNetworkResourcesForLiveStreamingWhilePaused = false

            player = AVPlayer(playerItem: item)
            player.actionAtItemEnd = .none
            player.automaticallyWaitsToMinimizeStalling = false

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        func primeForPlayback() {
            guard hasPrimedPlayback == false else { return }
            guard player.status == .readyToPlay else { return }
            hasPrimedPlayback = true

            player.preroll(atRate: 0.0) { [weak player] _ in
                player?.pause()
            }
        }

        deinit {
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
            }
        }
    }

    private var containers: [String: PlayerContainer] = [:]
    private var activeVideoID: String?

    func player(for video: PropertyVideo) -> AVPlayer {
        if let existing = containers[video.id] {
            return existing.player
        }

        let container = PlayerContainer(url: video.url)
        containers[video.id] = container
        return container.player
    }

    func syncPlayback(
        videos: [PropertyVideo],
        activeIndex: Int
    ) {
        guard videos.indices.contains(activeIndex) else { return }

        let retainedIDs = retainedVideoIDs(videos: videos, activeIndex: activeIndex)

        for video in videos where retainedIDs.contains(video.id) {
            let container = container(for: video)
            container.primeForPlayback()
        }

        for id in Array(containers.keys) {
            guard let container = containers[id] else { continue }

            guard retainedIDs.contains(id) else {
                container.player.pause()
                container.player.replaceCurrentItem(with: nil)
                containers[id] = nil
                continue
            }

            if id == videos[activeIndex].id {
                if activeVideoID != id {
                    container.player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                }
                container.player.playImmediately(atRate: 1.0)
            } else {
                container.player.pause()
            }
        }

        activeVideoID = videos[activeIndex].id
    }

    func pauseAll() {
        containers.values.forEach { $0.player.pause() }
    }

    private func container(for video: PropertyVideo) -> PlayerContainer {
        if let existing = containers[video.id] {
            return existing
        }

        let container = PlayerContainer(url: video.url)
        containers[video.id] = container
        return container
    }

    private func retainedVideoIDs(videos: [PropertyVideo], activeIndex: Int) -> Set<String> {
        guard videos.isEmpty == false else { return [] }
        guard videos.count > 2 else { return Set(videos.map(\.id)) }

        let previousIndex = (activeIndex - 1 + videos.count) % videos.count
        let nextIndex = (activeIndex + 1) % videos.count

        return [
            videos[previousIndex].id,
            videos[activeIndex].id,
            videos[nextIndex].id
        ]
    }
}
