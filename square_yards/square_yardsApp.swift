import AVFoundation
import SwiftUI

@main
struct square_yardsApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [])
            try session.setActive(true)
        } catch {
            assertionFailure("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}
