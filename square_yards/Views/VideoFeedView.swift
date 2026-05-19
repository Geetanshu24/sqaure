import SwiftUI

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()
    @StateObject private var playerPool = AVPlayerPool()
    @Environment(\.scenePhase) private var scenePhase
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            content
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            await viewModel.loadVideosIfNeeded()
        }
        .onChange(of: viewModel.selectedIndex) { _ in
            refreshPlayback()
        }
        .onChange(of: viewModel.activeLeadVideo) { _ in
            refreshPlayback()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                refreshPlayback()
            } else {
                playerPool.pauseAll()
            }
        }
        .onDisappear {
            playerPool.pauseAll()
        }
        .overlay(alignment: .bottom) {
            PropBottomSheet(
                isPresented: Binding(
                    get: { viewModel.activeLeadVideo != nil },
                    set: { isPresented in
                        if isPresented == false {
                            viewModel.dismissLeadForm()
                        }
                    }
                ),
                heightRatio: 0.5
            ) {
                if viewModel.activeLeadVideo != nil {
                    LeadFormView {
                        viewModel.dismissLeadForm()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading premium property videos...")
                .tint(.white)
                .foregroundStyle(.white)
        case .failed(let message):
            VStack(spacing: 12) {
                Text(message)
                    .font(.headline)
                    .foregroundStyle(.white)

                Button("Retry") {
                    Task {
                        await viewModel.retry()
                        refreshPlayback()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        case .loaded:
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                        VideoFeedPageView(
                            video: video,
                            player: playerPool.player(for: video),
                            isActive: viewModel.selectedIndex == index && viewModel.shouldPausePlayback == false,
                            onLeadTap: {
                                viewModel.showLeadForm(for: video)
                            }
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y: pageOffset(for: index, pageHeight: geometry.size.height))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onAppear {
                    refreshPlayback()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = interactiveDragOffset(
                                for: value.translation.height,
                                pageHeight: geometry.size.height
                            )
                        }
                        .onEnded { value in
                            handleDragEnd(
                                translation: value.translation.height,
                                predictedEndTranslation: value.predictedEndTranslation.height,
                                pageHeight: geometry.size.height
                            )
                        }
                )
            }
        }
    }

    private func refreshPlayback() {
        guard viewModel.videos.isEmpty == false else { return }

        if viewModel.shouldPausePlayback || scenePhase != .active {
            playerPool.pauseAll()
            return
        }

        playerPool.syncPlayback(
            videos: viewModel.videos,
            activeIndex: viewModel.selectedIndex
        )
    }

    private func pageOffset(for index: Int, pageHeight: CGFloat) -> CGFloat {
        CGFloat(circularDistance(from: viewModel.selectedIndex, to: index)) * pageHeight + dragOffset
    }

    private func handleDragEnd(
        translation: CGFloat,
        predictedEndTranslation: CGFloat,
        pageHeight: CGFloat
    ) {
        let threshold = pageHeight * 0.14
        let velocityContribution = (predictedEndTranslation - translation) * 0.18
        let projectedTravel = translation + velocityContribution
        let movingForward = projectedTravel < -threshold
        let movingBackward = projectedTravel > threshold
        var nextIndex = viewModel.selectedIndex

        if movingForward {
            nextIndex = wrappedIndex(viewModel.selectedIndex + 1)
        } else if movingBackward {
            nextIndex = wrappedIndex(viewModel.selectedIndex - 1)
        }

        guard viewModel.videos.isEmpty == false else {
            withAnimation(pageSnapAnimation) {
                dragOffset = 0
            }
            return
        }

        withAnimation(pageSnapAnimation) {
            dragOffset = 0
            viewModel.setSelectedIndex(nextIndex)
        }
    }

    private func interactiveDragOffset(for translation: CGFloat, pageHeight: CGFloat) -> CGFloat {
        let direction: CGFloat = translation >= 0 ? 1 : -1
        let distance = abs(translation)
        let limitedDistance = min(distance, pageHeight)
        let overflowDistance = max(0, distance - pageHeight)
        let dampedOverflow = pow(overflowDistance, 0.82) * 0.28
        return direction * (limitedDistance + dampedOverflow)
    }

    private var pageSnapAnimation: Animation {
        .interactiveSpring(response: 0.36, dampingFraction: 0.86, blendDuration: 0.12)
    }

    private func wrappedIndex(_ index: Int) -> Int {
        guard viewModel.videos.isEmpty == false else { return 0 }
        let count = viewModel.videos.count
        return ((index % count) + count) % count
    }

    private func circularDistance(from selectedIndex: Int, to index: Int) -> Int {
        let count = viewModel.videos.count
        guard count > 0 else { return 0 }

        var distance = index - selectedIndex
        let half = count / 2

        if distance > half {
            distance -= count
        } else if distance < -half {
            distance += count
        }

        return distance
    }
}
