import SwiftUI

struct LibraryView: View {
    @ObservedObject var favorites = FavoritesManager.shared
    @ObservedObject var cacheService = AudioCacheService.shared
    @ObservedObject var player = AudioPlayerManager.shared
    @State private var selectedTab: Int = 0 // 0 = Favorit, 1 = Terunduh

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Koleksi Musik")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedTab == 1 && !cacheService.downloadedSongs.isEmpty {
                        Text(cacheService.getCacheSizeString())
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Segmented Selector
                Picker("Koleksi", selection: $selectedTab) {
                    Text("Favorit (\(favorites.favoriteSongs.count))").tag(0)
                    Text("Terunduh (\(cacheService.downloadedSongs.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                if selectedTab == 0 {
                    favoritesSection
                } else {
                    downloadsSection
                }
            }
        }
    }

    private var favoritesSection: some View {
        Group {
            if favorites.favoriteSongs.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "heart.slash")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text("Belum Ada Lagu Favorit")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Tekan ikon hati pada lagu apa pun untuk menambahkannya ke sini.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(favorites.favoriteSongs) { song in
                        SongRow(song: song, onPlay: {
                            player.play(song: song)
                        })
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let song = favorites.favoriteSongs[index]
                            favorites.toggleFavorite(song: song)
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 120)
            }
        }
    }

    private var downloadsSection: some View {
        Group {
            if cacheService.downloadedSongs.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text("Belum Ada Lagu Terunduh")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Lagu yang didownload akan tersimpan di disk lokal dan bisa diputar tanpa internet.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(cacheService.downloadedSongs) { song in
                        HStack(spacing: 8) {
                            SongRow(song: song, onPlay: {
                                player.play(song: song)
                            })

                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                                .padding(.trailing, 16)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let song = cacheService.downloadedSongs[index]
                            cacheService.removeDownload(id: song.id)
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 120)
            }
        }
    }
}
