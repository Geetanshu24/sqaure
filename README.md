# Square Yards iOS Assignment

This project implements the machine test as a SwiftUI-first MVVM app for iOS.

## What's Included

- Vertical Reels-style property feed with snap paging
- Inline autoplay for the active video and paused off-screen playback
- Global mute state shared across the full feed
- Overlay metadata with delayed auto-hide for an immersive playback feel
- Reusable `PropBottomSheet` with drag-to-dismiss and dimmed backdrop
- Lead form with validation and keyboard-safe scrolling
- Bundled static `videos.json` data source so the assignment runs without any API key or backend setup

## Architecture

- `Models`: feed and lead form entities
- `ViewModels`: screen state, player orchestration, and form validation
- `Services`: local data loading abstraction for the bundled JSON feed
- `Utilities`: keyboard handling and pooled AVPlayer lifecycle management
- `Components` / `Views`: reusable UI building blocks and screen composition

## Notes

- The player pool preloads the current, previous, and next items only, then releases distant players to keep memory usage predictable.
- The feed is powered by a bundled JSON file so the app remains deterministic and easy to review.
