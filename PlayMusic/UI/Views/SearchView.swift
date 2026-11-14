import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    @State private var searchResults: [Song] = []
    @State private var suggestions: [String] = []
    @State private var isSearching: Bool = false
    @State private var suggestionTask: Task<Void, Never>? = nil
    @ObservedObject var player = AudioPlayerManager.shared

    let browseCategories = [
        ("Pop Indonesia", "flame.fill", Color.red),
        ("Top Global 50", "globe.asia.australia.fill", Color.blue),
        ("Santai & Akustik", "cup.and.saucer.fill", Color.orange),
        ("Workout & Hype", "bolt.fill", Color.yellow),
        ("Lofi & Chill", "moon.stars.fill", Color.purple),
        ("Hip Hop Indo", "headphones", Color.pink),
        ("Rock Klasik", "guitars.fill", Color.indigo),
        ("Jazz Cafe", "music.quarternote.3", Color.teal)
    ]

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Cari")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("Artis, lagu, lirik, dan lainnya", text: $query)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: query) { newText in
                            fetchSuggestions(for: newText)
                        }
                        .onSubmit {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            performSearch(q: query)
                        }

                    if !query.isEmpty {
                        Button(action: {
                            query = ""
                            searchResults = []
                            suggestions = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Results or Explore Grid
                if isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if !suggestions.isEmpty && searchResults.isEmpty && !query.isEmpty {
                    // Live Search Autocomplete Suggestions list (seperti YouTube / Apple Music)
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(suggestions, id: \.self) { item in
                                Button(action: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    query = item
                                    suggestions = []
                                    performSearch(q: item)
                                }) {
                                    HStack(spacing: 14) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)

                                        Text(item)
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Image(systemName: "arrow.up.left")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary.opacity(0.5))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 13)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                Divider()
                                    .padding(.leading, 50)
                            }
                        }
                        .padding(.bottom, 130)
                    }
                } else if !searchResults.isEmpty {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            ForEach(searchResults) { song in
                                SongRow(song: song, onPlay: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    player.play(song: song)
                                })
                            }
                        }
                        .padding(.bottom, 130)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Jelajahi Kategori")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(browseCategories, id: \.0) { cat in
                                    Button(action: {
                                        query = cat.0
                                        performSearch(q: cat.0)
                                    }) {
                                        ZStack(alignment: .bottomLeading) {
                                            LinearGradient(
                                                colors: [cat.2.opacity(0.85), cat.2.opacity(0.45)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .frame(height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                            HStack {
                                                Text(cat.0)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                Image(systemName: cat.1)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.white.opacity(0.35))
                                            }
                                            .padding(14)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 130)
                    }
                }
            }
        }
    }

    private func performSearch(q: String) {
        guard !q.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        suggestions = []
        Task {
            do {
                let songs = try await InnertubeService.shared.search(query: q)
                await MainActor.run {
                    self.searchResults = songs
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                }
            }
        }
    }

    private func fetchSuggestions(for text: String) {
        suggestionTask?.cancel()
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            suggestions = []
            return
        }
        suggestionTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            let res = await InnertubeService.shared.getSearchSuggestions(query: text)
            await MainActor.run {
                if self.query == text && self.searchResults.isEmpty {
                    self.suggestions = res
                }
            }
        }
    }
}
