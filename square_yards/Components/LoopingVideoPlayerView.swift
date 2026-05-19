import AVFoundation
import SwiftUI

struct LoopingVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    @Binding var isReadyForDisplay: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isReadyForDisplay: $isReadyForDisplay)
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.backgroundColor = .clear
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.backgroundColor = UIColor.clear.cgColor
        view.playerLayer.player = player
        context.coordinator.bind(to: view.playerLayer)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
        context.coordinator.bind(to: uiView.playerLayer)
    }

    final class Coordinator: NSObject {
        @Binding private var isReadyForDisplay: Bool
        private var observation: NSKeyValueObservation?
        private var observedLayerIdentifier: ObjectIdentifier?

        init(isReadyForDisplay: Binding<Bool>) {
            _isReadyForDisplay = isReadyForDisplay
        }

        func bind(to layer: AVPlayerLayer) {
            let layerIdentifier = ObjectIdentifier(layer)
            guard observedLayerIdentifier != layerIdentifier else { return }

            observation?.invalidate()
            observedLayerIdentifier = layerIdentifier
            DispatchQueue.main.async { [weak self] in
                self?.isReadyForDisplay = layer.isReadyForDisplay
            }
            observation = layer.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] layer, _ in
                DispatchQueue.main.async {
                    self?.isReadyForDisplay = layer.isReadyForDisplay
                }
            }
        }
    }
}

final class PlayerView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}
