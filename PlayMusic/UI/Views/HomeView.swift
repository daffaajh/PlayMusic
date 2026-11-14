import SwiftUI

struct HomeView: View {
    @State private var trendingSongs: [Song] = []
    @State private var popularPlaylists: [Song] = []
    @State private var isLoadingTrending: Bool = true
    @State private var selectedGenre: String? = nil
    @ObservedObject var player = AudioPlayerManager.shared

    let genres = ["Semua", "Pop", "Indie", "Rock", "R&B", "Akustik", "Lofi", "Elektronik"]

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Sleek Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BERANDA")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.4)
                        Text("Dengarkan Sekarang")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 12)

                // Genre Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            let isCurrent = (selectedGenre == genre) || (selectedGenre == nil && genre == "Semua")
                            Button(action: {
                                selectedGenre = genre == "Semua" ? nil : genre
                                if let g = selectedGenre {
                                    loadGenre(g)
                                } else {
                                    loadTrending()
                                }
                            }) {
                                Text(genre)
                                    .font(.system(size: 13, weight: isCurrent ? .bold : .medium, design: .rounded))
                                    .foregroundColor(isCurrent ? Color(UIColor.systemBackground) : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(isCurrent ? Color.primary : Color(UIColor.secondarySystemBackground))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)

                // Content
                if isLoadingTrending {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.1)
                        Text("Memuat kurasi musik...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if trendingSongs.isEmpty && popularPlaylists.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Tidak Ada Koneksi Internet")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Periksa jaringan internet atau putar lagu yang telah disimpan di tab Koleksi.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: {
                            loadTrending()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                Text("Coba Lagi")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.blue))
                        }
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 26) {
                            // Section 1: Tangga Lagu & Playlist Populer (Horizontal Carousel Card)
                            if !popularPlaylists.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text("Tangga Lagu & Playlist Pilihan")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(popularPlaylists) { item in
                                                Button(action: {
                                                    player.play(song: item)
                                                }) {
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        ZStack(alignment: .bottomTrailing) {
                                                            AsyncImage(url: item.highResThumbnail) { phase in
                                                                if let image = phase.image {
                                                                    image.resizable().scaledToFill()
                                                                } else {
                                                                    Color.secondary.opacity(0.15)
                                                                }
                                                            }
                                                            .frame(width: 145, height: 145)
                                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 5)

                                                            Image(systemName: "play.circle.fill")
                                                                .font(.system(size: 28))
                                                                .foregroundColor(.white)
                                                                .shadow(radius: 4)
                                                                .padding(8)
                                                        }

                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(item.title)
                                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                                .foregroundColor(.primary)
                                                                .lineLimit(1)
                                                            Text(item.artist)
                                                                .font(.system(size: 12, weight: .medium))
                                                                .foregroundColor(.secondary)
                                                                .lineLimit(1)
                                                        }
                                                        .frame(width: 145, alignment: .leading)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            // Section 2: Rekomendasi Teratas
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Lagu Rekomendasi Teratas")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(trendingSongs.count) lagu")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)

                                LazyVStack(spacing: 6) {
                                    ForEach(trendingSongs) { song in
                                        SongRow(song: song, onPlay: {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            player.play(song: song)
                                        })
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 130)
                    }
                    .refreshable {
                        loadTrending()
                    }
                }
            }
        }
        .onAppear {
            if trendingSongs.isEmpty {
                loadTrending()
            }
        }
    }

    private func loadTrending() {
        isLoadingTrending = true
        Task {
            do {
                async let indoHits = InnertubeService.shared.search(query: "Top Hits Indonesia Terbaru")
                async let globalHits = InnertubeService.shared.search(query: "Billboard Hot 100")
                async let playlists = InnertubeService.shared.search(query: "Lagu Viral Populer Indonesia")

                let (indo, global, playListRes) = await (try? indoHits, try? globalHits, try? playlists)
                
                var combined: [Song] = []
                var seen = Set<String>()
                
                for s in (indo ?? []) + (global ?? []) {
                    if !seen.contains(s.id) {
                        seen.insert(s.id)
                        combined.append(s)
                    }
                }
                
                await MainActor.run {
                    self.trendingSongs = combined
                    self.popularPlaylists = playListRes ?? []
                    self.isLoadingTrending = false
                }
            }
        }
    }

    private func loadGenre(_ g: String) {
        isLoadingTrending = true
        Task {
            do {
                let songs = try await InnertubeService.shared.search(query: "\(g) music indonesia hits")
                await MainActor.run {
                    self.trendingSongs = songs
                    self.isLoadingTrending = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingTrending = false
                }
            }
        }
    }
}

struct SongRow: View {
    let song: Song
    var onPlay: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                onPlay?()
            }) {
                HStack(spacing: 12) {
                    AsyncImage(url: song.highResThumbnail) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            ZStack {
                                Color(UIColor.secondarySystemBackground)
                                Image(systemName: "music.note")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(song.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Text(song.artist)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            if let album = song.album {
                                Text("•")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.6))
                                Text(album)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            Menu {
                Button(action: {
                    FavoritesManager.shared.toggleFavorite(song: song)
                }) {
                    Label(
                        FavoritesManager.shared.isFavorite(songId: song.id) ? "Hapus dari Favorit" : "Tambah ke Favorit",
                        systemImage: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.slash" : "heart"
                    )
                }

                Button(action: {
                    if AudioCacheService.shared.isDownloaded(id: song.id) {
                        AudioCacheService.shared.removeDownload(id: song.id)
                    } else {
                        Task {
                            if let streamURL = try? await InnertubeService.shared.getStreamURL(videoId: song.id) {
                                try? await AudioCacheService.shared.downloadExplicitly(song: song, remoteURL: streamURL)
                            }
                        }
                    }
                }) {
                    Label(
                        AudioCacheService.shared.isDownloaded(id: song.id) ? "Hapus Unduhan" : "Download Lagu",
                        systemImage: AudioCacheService.shared.isDownloaded(id: song.id) ? "trash" : "arrow.down.circle"
                    )
                }

                Button(action: {
                    AudioPlayerManager.shared.playNext(song)
                }) {
                    Label("Putar Berikutnya", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                Button(action: {
                    AudioPlayerManager.shared.addToQueue(song)
                }) {
                    Label("Tambah ke Antrean", systemImage: "text.badge.plus")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}
