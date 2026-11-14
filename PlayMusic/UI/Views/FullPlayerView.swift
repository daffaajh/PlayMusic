import SwiftUI

struct FullPlayerView: View {
    @ObservedObject var player = AudioPlayerManager.shared
    @ObservedObject var cacheService = AudioCacheService.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showLyrics: Bool = true
    @State private var showQueueSheet: Bool = false
    @State private var isUserScrollingLyrics: Bool = false
    @State private var lyricResumeTask: Task<Void, Never>? = nil
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var isLight: Bool {
        colorScheme == .light
    }

    // Dynamic Palette based on Active Theme
    private var primaryText: Color {
        isLight ? Color.black : Color.white
    }

    private var secondaryText: Color {
        isLight ? Color.black.opacity(0.65) : Color.white.opacity(0.65)
    }

    private var tertiaryText: Color {
        isLight ? Color.black.opacity(0.35) : Color.white.opacity(0.35)
    }

    private var buttonBg: Color {
        isLight ? Color.black.opacity(0.08) : Color.white.opacity(0.14)
    }

    private var buttonActiveBg: Color {
        isLight ? Color.black.opacity(0.18) : Color.white.opacity(0.28)
    }

    private var capsuleBg: Color {
        isLight ? Color.black.opacity(0.25) : Color.white.opacity(0.35)
    }

    var body: some View {
        ZStack {
            // Adaptive Background
            (isLight ? Color(UIColor.systemBackground) : Color.black).ignoresSafeArea()
            
            if let song = player.currentSong {
                AsyncImage(url: song.highResThumbnail) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .blur(radius: isLight ? 70 : 60)
                            .opacity(isLight ? 0.22 : 0.4)
                    }
                }
                .ignoresSafeArea()
            }

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .sheet(isPresented: $showQueueSheet) {
            QueueSheetView()
                .preferredColorScheme(ThemeManager.shared.selectedTheme.colorScheme)
        }
    }

    // MARK: - Landscape Layout
    private var landscapeLayout: some View {
        VStack(spacing: 8) {
            // Top Bar
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                        Text("Tutup")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(buttonBg))
                }

                Spacer()

                Capsule()
                    .fill(capsuleBg)
                    .frame(width: 36, height: 4)

                Spacer()

                HStack(spacing: 12) {
                    if let song = player.currentSong {
                        // Download button
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if cacheService.isDownloaded(id: song.id) {
                                cacheService.removeDownload(id: song.id)
                            } else {
                                Task {
                                    if let streamURL = try? await InnertubeService.shared.getStreamURL(videoId: song.id) {
                                        try? await cacheService.downloadExplicitly(song: song, remoteURL: streamURL)
                                    }
                                }
                            }
                        }) {
                            if cacheService.activeDownloads.contains(song.id) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: primaryText))
                                    .scaleEffect(0.7)
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(buttonBg))
                            } else {
                                Image(systemName: cacheService.isDownloaded(id: song.id) ? "arrow.down.circle.fill" : "arrow.down.circle")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(cacheService.isDownloaded(id: song.id) ? .green : primaryText)
                                    .padding(6)
                                    .background(Circle().fill(buttonBg))
                            }
                        }

                        // Favorite button
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            FavoritesManager.shared.toggleFavorite(song: song)
                        }) {
                            Image(systemName: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(FavoritesManager.shared.isFavorite(songId: song.id) ? .red : primaryText)
                                .padding(6)
                                .background(Circle().fill(buttonBg))
                        }
                    }

                    // Lyrics toggle
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            showLyrics.toggle()
                        }
                    }) {
                        Image(systemName: showLyrics ? "quote.bubble.fill" : "quote.bubble")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(primaryText)
                            .padding(6)
                            .background(Circle().fill(showLyrics ? buttonActiveBg : buttonBg))
                    }

                    // Queue button
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showQueueSheet = true
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(primaryText)
                            .padding(6)
                            .background(Circle().fill(buttonBg))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)

            // Body 2-Column Split
            HStack(spacing: 24) {
                // Kolom Kiri: Cover Art & Info Lagu
                VStack(spacing: 8) {
                    if let song = player.currentSong {
                        AsyncImage(url: song.highResThumbnail) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(maxWidth: 155, maxHeight: 155)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: isLight ? Color.black.opacity(0.12) : Color.black.opacity(0.35), radius: 10, x: 0, y: 5)

                        VStack(spacing: 2) {
                            Text(song.title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(primaryText)
                                .lineLimit(1)
                            Text(song.artist)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(secondaryText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: 180)
                    }
                }
                .padding(.leading, 24)

                // Kolom Kanan: Kontrol Pemutar atau Lirik
                if showLyrics {
                    lyricsSection
                        .frame(maxHeight: .infinity)
                        .padding(.trailing, 24)
                } else {
                    landscapeControls
                        .padding(.trailing, 24)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.vertical, 6)
    }

    private var landscapeControls: some View {
        VStack(spacing: 12) {
            Spacer()

            // Scrubber Slider & Durasi
            VStack(spacing: 6) {
                Slider(value: Binding(
                    get: { player.currentTime },
                    set: { player.seek(to: $0) }
                ), in: 0...max(player.duration, 1))
                .accentColor(primaryText)

                HStack {
                    Text(formatTime(player.currentTime))
                    Spacer()
                    Text(formatTime(player.duration))
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(secondaryText)
            }

            // Tombol Kontrol Playback Compact
            HStack(spacing: 28) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.toggleShuffle()
                }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 16))
                        .foregroundColor(player.isShuffle ? (isLight ? .blue : .white) : tertiaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.playPreviousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    player.togglePlayPause()
                }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(isLight ? .white : .black)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(primaryText))
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.playNextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.toggleRepeatMode()
                }) {
                    Image(systemName: player.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 16))
                        .foregroundColor(player.repeatMode == .off ? tertiaryText : (isLight ? .blue : .white))
                }
            }

            // Bar AirPlay Compact
            HStack {
                Spacer()
                AirPlayButtonView()
                    .frame(width: 28, height: 28)
            }

            Spacer()
        }
    }

    // MARK: - Portrait Layout
    private var portraitLayout: some View {
        VStack(spacing: 16) {
            // Header atas
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(primaryText)
                        .padding(10)
                        .background(Circle().fill(buttonBg))
                }

                Spacer()

                Capsule()
                    .fill(capsuleBg)
                    .frame(width: 36, height: 5)

                Spacer()

                HStack(spacing: 12) {
                    if let song = player.currentSong {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if cacheService.isDownloaded(id: song.id) {
                                cacheService.removeDownload(id: song.id)
                            } else {
                                Task {
                                    if let streamURL = try? await InnertubeService.shared.getStreamURL(videoId: song.id) {
                                        try? await cacheService.downloadExplicitly(song: song, remoteURL: streamURL)
                                    }
                                }
                            }
                        }) {
                            if cacheService.activeDownloads.contains(song.id) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: primaryText))
                                    .scaleEffect(0.8)
                                    .padding(10)
                                    .background(Circle().fill(buttonBg))
                            } else {
                                Image(systemName: cacheService.isDownloaded(id: song.id) ? "arrow.down.circle.fill" : "arrow.down.circle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(cacheService.isDownloaded(id: song.id) ? .green : primaryText)
                                    .padding(10)
                                    .background(Circle().fill(buttonBg))
                            }
                        }

                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            FavoritesManager.shared.toggleFavorite(song: song)
                        }) {
                            Image(systemName: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(FavoritesManager.shared.isFavorite(songId: song.id) ? .red : primaryText)
                                .padding(10)
                                .background(Circle().fill(buttonBg))
                        }
                    }

                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showLyrics.toggle()
                        }
                    }) {
                        Image(systemName: showLyrics ? "quote.bubble.fill" : "quote.bubble")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryText)
                            .padding(10)
                            .background(Circle().fill(showLyrics ? buttonActiveBg : buttonBg))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)

            Spacer(minLength: 8)

            if showLyrics {
                lyricsSection
                    .frame(maxHeight: 330)
            } else {
                artworkSection
            }

            Spacer(minLength: 8)

            metaAndControlsSection
                .padding(.bottom, 24)
        }
    }

    private var artworkSection: some View {
        VStack {
            if let song = player.currentSong {
                AsyncImage(url: song.highResThumbnail) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: isLight ? Color.black.opacity(0.15) : Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                .liquidGlass(cornerRadius: 28, allowsDragPhysics: true)
            }
        }
    }

    private var lyricsSection: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    if let lyrics = player.lyrics, lyrics.isSynced {
                        ForEach(Array(lyrics.lines.enumerated()), id: \.element.id) { index, line in
                            let isCurrent = player.currentLyricIndex == index
                            let isPast = (player.currentLyricIndex ?? -1) > index
                            
                            Text(line.text)
                                .font(.system(size: isCurrent ? 28 : 22, weight: .bold, design: .rounded))
                                .foregroundColor(isCurrent ? primaryText : (isPast ? primaryText.opacity(0.4) : primaryText.opacity(0.2)))
                                .blur(radius: isCurrent ? 0 : 0.6)
                                .scaleEffect(isCurrent ? 1.04 : 0.98, anchor: .leading)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isCurrent)
                                .id(index)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    player.seek(to: Double(line.timestampMs) / 1000.0)
                                    isUserScrollingLyrics = false
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                        }
                    } else if let raw = player.lyrics?.rawText {
                        Text(raw)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryText.opacity(0.85))
                            .lineSpacing(10)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "music.mic")
                                .font(.system(size: 36))
                                .foregroundColor(tertiaryText)
                            Text("Lirik lagu tidak tersedia")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(secondaryText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        isUserScrollingLyrics = true
                        lyricResumeTask?.cancel()
                        lyricResumeTask = Task {
                            try? await Task.sleep(nanoseconds: 3_500_000_000)
                            await MainActor.run {
                                isUserScrollingLyrics = false
                                if let idx = player.currentLyricIndex {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
            )
            .onReceive(player.$currentLyricIndex) { newIndex in
                if let idx = newIndex, !isUserScrollingLyrics {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
        }
    }

    private var metaAndControlsSection: some View {
        VStack(spacing: 20) {
            if let song = player.currentSong {
                VStack(spacing: 6) {
                    Text(song.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(primaryText)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(secondaryText)
                        .lineLimit(1)
                }
                .padding(.horizontal, 28)
                .padding(.top, 10)
            }

            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { player.currentTime },
                    set: { player.seek(to: $0) }
                ), in: 0...max(player.duration, 1))
                .accentColor(primaryText)

                HStack {
                    Text(formatTime(player.currentTime))
                    Spacer()
                    Text(formatTime(player.duration))
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(secondaryText)
            }
            .padding(.horizontal, 28)

            HStack(spacing: 40) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.toggleShuffle()
                }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 20))
                        .foregroundColor(player.isShuffle ? (isLight ? .blue : .white) : tertiaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.playPreviousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 24))
                        .foregroundColor(primaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    player.togglePlayPause()
                }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isLight ? .white : .black)
                        .frame(width: 76, height: 76)
                        .background(Circle().fill(primaryText))
                        .overlay(Circle().stroke(isLight ? Color.black.opacity(0.1) : Color.white.opacity(0.25), lineWidth: 1))
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.playNextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                        .foregroundColor(primaryText)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    player.toggleRepeatMode()
                }) {
                    Image(systemName: player.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 20))
                        .foregroundColor(player.repeatMode == .off ? tertiaryText : (isLight ? .blue : .white))
                }
            }
            .padding(.top, 8)

            // Bar AirPlay & Tombol Antrean (Queue)
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showQueueSheet = true
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(secondaryText)
                        .padding(8)
                        .background(Circle().fill(buttonBg))
                }

                Spacer()

                AirPlayButtonView()
                    .frame(width: 32, height: 32)

                Spacer()

                Color.clear
                    .frame(width: 34, height: 34)
            }
            .padding(.horizontal, 28)
            .padding(.top, 10)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let total = Int(seconds)
        let min = total / 60
        let sec = total % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
