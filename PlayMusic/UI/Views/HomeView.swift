import SwiftUI

struct HomeView: View {
    @State private var trendingSongs: [Song] = []
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
                                    .foregroundColor(isCurrent ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(isCurrent ? Color.primary : Color(UIColor.secondarySystemBackground))
                                    )
                                    .colorInvert(isCurrent ? true : false)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)

                // Song List
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
                } else if trendingSongs.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "music.note.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Belum ada lagu tersedia")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            HStack {
                                Text("Lagu Populer & Rekomendasi")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(trendingSongs.count) lagu")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 6)

                            ForEach(trendingSongs) { song in
                                SongRow(song: song)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        player.play(song: song)
                                    }
                            }
                        }
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

    func loadTrending() {
        isLoadingTrending = true
        Task {
            do {
                // Algoritma rekomendasi multi-query untuk feed yang kaya
                async let indoHits = InnertubeService.shared.search(query: "Lagu Pop Indonesia Terpopuler 2024")
                async let globalHits = InnertubeService.shared.search(query: "Top Global Hits Billboard")
                
                let (indo, global) = await (try? indoHits, try? globalHits)
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
                    self.isLoadingTrending = false
                }
            }
        }
    }

    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        Task {
            do {
                let results = try await InnertubeService.shared.search(query: query)
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                }
            }
        }
    }
}

struct SongRow: View {
    let song: Song

    var body: some View {
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.8))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}
