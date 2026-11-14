import SwiftUI

struct HomeView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [Song] = []
    @State private var trendingSongs: [Song] = []
    @State private var isSearching: Bool = false
    @State private var isLoadingTrending: Bool = true
    @State private var selectedGenre: String? = nil
    @ObservedObject var player = AudioPlayerManager.shared

    let genres = ["All", "Pop", "Indie", "Rock", "R&B", "Acoustic", "Jazz", "Electronic"]

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Text("PlayMusic")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search songs, artists...", text: $searchQuery)
                        .foregroundColor(.primary)
                        .onSubmit {
                            performSearch(query: searchQuery)
                        }
                    
                    if !searchQuery.isEmpty {
                        Button(action: {
                            searchQuery = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .liquidGlass(cornerRadius: 20, allowsDragPhysics: false)
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            let isCurrent = (selectedGenre == genre) || (selectedGenre == nil && genre == "All")
                            Button(action: {
                                selectedGenre = genre == "All" ? nil : genre
                                if let g = selectedGenre {
                                    performSearch(query: "\(g) music hits")
                                } else {
                                    searchQuery = ""
                                    searchResults = []
                                }
                            }) {
                                Text(genre)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isCurrent ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(isCurrent ? Color.blue : Color.secondary.opacity(0.12))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if isSearching || (isLoadingTrending && searchResults.isEmpty && searchQuery.isEmpty) {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List {
                        let displaySongs = searchQuery.isEmpty ? trendingSongs : searchResults
                        
                        if searchQuery.isEmpty && !trendingSongs.isEmpty {
                            Text("Trending Now")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.top, 4)
                        }
                        
                        ForEach(displaySongs) { song in
                            SongRow(song: song)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    player.play(song: song)
                                }
                        }
                    }
                    .listStyle(.plain)
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
                let songs = try await InnertubeService.shared.getTrending()
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
        HStack(spacing: 14) {
            AsyncImage(url: song.highResThumbnail) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.white.opacity(0.08)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Menu {
                Button(action: {
                    FavoritesManager.shared.toggleFavorite(song: song)
                }) {
                    Label(
                        FavoritesManager.shared.isFavorite(songId: song.id) ? "Remove Favorite" : "Add to Favorite",
                        systemImage: FavoritesManager.shared.isFavorite(songId: song.id) ? "heart.slash" : "heart"
                    )
                }
                Button(action: {
                    AudioPlayerManager.shared.playNext(song)
                }) {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                Button(action: {
                    AudioPlayerManager.shared.addToQueue(song)
                }) {
                    Label("Add to Queue", systemImage: "text.badge.plus")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 18, allowsDragPhysics: false)
        .padding(.vertical, 2)
    }
}
