import AVFoundation
import SwiftUI

struct VideoFeedPageView: View {
    let video: PropertyVideo
    let player: AVPlayer
    let isActive: Bool
    let onLeadTap: () -> Void

    @State private var isPlayerReady = false
    @State private var isPlaybackPaused = false

    var body: some View {
        ZStack {
            posterBackground
            LoopingVideoPlayerView(player: player, isReadyForDisplay: $isPlayerReady)
                .ignoresSafeArea()
                .opacity(isPlayerReady ? 1 : 0)
                .allowsHitTesting(false)
            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.14),
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer()
                overlay
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 24)

            if isPlaybackPaused {
                centerPauseBadge
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handlePageTap()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                isPlaybackPaused = false
            } else {
                isPlayerReady = false
            }
        }
    }

    private var posterBackground: some View {
        GeometryReader { geometry in
            AsyncImage(url: video.thumbnailURL) { image in
                styledPoster(
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                )
            } placeholder: {
                fallbackPoster
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }

    private var fallbackPoster: some View {
        styledPoster(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.16, blue: 0.31),
                        Color(red: 0.04, green: 0.05, blue: 0.08),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: 18) {
                    Spacer()

                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 92))
                        .foregroundStyle(.white.opacity(0.18))

                    Text(video.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 28)

                    Text(video.location)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()
                }
            }
        )
    }

    private func styledPoster<Content: View>(_ content: Content) -> some View {
        ZStack {
            content
                .saturation(0.82)
                .contrast(0.9)
                .brightness(-0.05)
                .scaleEffect(1.035)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.08), Color.black.opacity(0.02), Color.black.opacity(0.22)],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.12), Color.black.opacity(0.42)],
                startPoint: .top,
                endPoint: .bottom
            )

            Rectangle()
                .fill(Color.black.opacity(0.06))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Color(red: 0.25, green: 0.31, blue: 0.41).opacity(0.92))
                .clipShape(Circle())
        }
    }

    private var overlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Label(video.tag, systemImage: "building.columns")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.yellow)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow.opacity(0.85), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
         
            VStack(alignment: .leading, spacing: 7) {
                Text(primaryTitle)
                    .font(.system(size: 23, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: .black.opacity(0.28), radius: 8, y: 2)

                Text(video.attributedSubtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Label(video.location, systemImage: "location")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Label("\(formattedViews) views", systemImage: "eye")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 14) {
                Button(action: onLeadTap) {
                    Image(systemName: "message")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 48)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)

                Button(action: onLeadTap) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                        Text("Get a Call Back")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.87, blue: 0.18), Color(red: 0.98, green: 0.81, blue: 0.11)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.16), radius: 10, y: 5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 2)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var centerPauseBadge: some View {
        Circle()
            .fill(Color.black.opacity(0.22))
            .frame(width: 72, height: 72)
            .overlay {
                Image(systemName: "pause.fill")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
            }
    }

    private var formattedViews: String {
        if video.viewCount >= 1_000 {
            return String(format: "%.1fK", Double(video.viewCount) / 1_000).replacingOccurrences(of: ".0", with: "")
        }
        return "\(video.viewCount)"
    }

    private var primaryTitle: String {
        video.title.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? video.title
    }

    private func handlePageTap() {
        togglePlayback()
    }

    private func togglePlayback() {
        isPlaybackPaused.toggle()

        if isPlaybackPaused {
            player.pause()
        } else if isActive {
            player.play()
        }
    }
}
