import SwiftUI

struct FullPlayerView: View {
    @ObservedObject var player = AudioPlayerManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showLyrics: Bool = true
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let song = player.currentSong {
                AsyncImage(url: song.highResThumbnail) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .blur(radius: 60)
                            .opacity(0.4)
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
    }

    private var landscapeLayout: some View {
        HStack(spacing: 32) {
            VStack {
                if let song = player.currentSong {
                    AsyncImage(url: song.highResThumbnail) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(maxWidth: 220, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .liquidGlass(cornerRadius: 20, allowsDragPhysics: false)
                }
            }
            .padding(.leading, 32)

            VStack(spacing: 16) {
                if showLyrics {
                    lyricsSection
                        .frame(maxHeight: 180)
                } else {
                    metaAndControlsSection
                }

                HStack {
                    if let song = player.currentSong {
                        Button(action: {
                            FavoritesManager.shared.toggleFavorite(song: song)
                        }) {
                            Image(systemName: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(FavoritesManager.shared.isFavorite(songId: song.id) ? .red : .white)
                                .padding(8)
                                .liquidGlass(cornerRadius: 14, allowsDragPhysics: false)
                        }
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(.spring()) {
                            showLyrics.toggle()
                        }
                    }) {
                        Image(systemName: showLyrics ? "quote.bubble.fill" : "quote.bubble")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(8)
                            .liquidGlass(cornerRadius: 14, allowsDragPhysics: false)
                    }
                }
                .padding(.horizontal, 28)
            }
            .padding(.trailing, 32)
        }
        .padding(.vertical, 16)
    }

    private var portraitLayout: some View {
        VStack(spacing: 20) {
            // Top Bar: Dismiss Grabber & Back Button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }

                Spacer()

                Capsule()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 36, height: 5)

                Spacer()

                HStack(spacing: 12) {
                    if let song = player.currentSong {
                        Button(action: {
                            FavoritesManager.shared.toggleFavorite(song: song)
                        }) {
                            Image(systemName: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(FavoritesManager.shared.isFavorite(songId: song.id) ? .red : .white)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.12)))
                        }
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showLyrics.toggle()
                        }
                    }) {
                        Image(systemName: showLyrics ? "quote.bubble.fill" : "quote.bubble")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(showLyrics ? Color.white.opacity(0.28) : Color.white.opacity(0.12)))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)

            Spacer()

            if showLyrics {
                lyricsSection
                    .frame(maxHeight: 380)
            } else {
                artworkSection
            }

            Spacer()

            metaAndControlsSection
                .padding(.bottom, 36)
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
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.black.opacity(0.5), radius: 25, x: 0, y: 15)
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
                                .foregroundColor(isCurrent ? .white : (isPast ? .white.opacity(0.35) : .white.opacity(0.2)))
                                .blur(radius: isCurrent ? 0 : 0.8)
                                .scaleEffect(isCurrent ? 1.04 : 0.98, anchor: .leading)
                                .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isCurrent)
                                .id(index)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        player.seek(to: Double(line.timestampMs) / 1000.0)
                                    }
                                }
                        }
                    } else if let raw = player.lyrics?.rawText {
                        Text(raw)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(10)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "music.mic")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.3))
                            Text("Lirik tidak tersedia")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
            }
            .onChange(of: player.currentLyricIndex) { newIndex in
                if let idx = newIndex {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
        }
    }

    private var metaAndControlsSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(song.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
            }
            .padding(.horizontal, 28)
            .padding(.top, 10)

            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { player.currentTime },
                    set: { player.seek(to: $0) }
                ), in: 0...max(player.duration, 1))
                .accentColor(.white)

                HStack {
                    Text(formatTime(player.currentTime))
                    Spacer()
                    Text(formatTime(player.duration))
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 28)

            HStack(spacing: 40) {
                Button(action: {
                    player.toggleShuffle()
                }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 20))
                        .foregroundColor(player.isShuffle ? .white : .white.opacity(0.35))
                }

                Button(action: {
                    player.seek(to: max(0, player.currentTime - 10))
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }

                Button(action: {
                    player.togglePlayPause()
                }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 76, height: 76)
                        .background(Circle().fill(Color.white.opacity(0.18)))
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                }

                Button(action: {
                    player.seek(to: min(player.duration, player.currentTime + 10))
                }) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }

                Button(action: {
                    player.toggleRepeatMode()
                }) {
                    Image(systemName: player.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 20))
                        .foregroundColor(player.repeatMode == .off ? .white.opacity(0.35) : .white)
                }
            }
            .padding(.top, 8)

            HStack(spacing: 16) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                
                AirPlayButtonView()
                    .frame(width: 32, height: 32)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
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
