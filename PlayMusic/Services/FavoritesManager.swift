import Foundation

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteSongs: [Song] = []
    private let storageKey = "user_favorite_songs_v1"

    init() {
        loadFavorites()
    }

    func isFavorite(songId: String) -> Bool {
        favoriteSongs.contains(where: { $0.id == songId })
    }

    func toggleFavorite(song: Song) {
        if isFavorite(songId: song.id) {
            favoriteSongs.removeAll(where: { $0.id == song.id })
        } else {
            favoriteSongs.insert(song, at: 0)
        }
        saveFavorites()
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteSongs) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Song].self, from: data)
            self.favoriteSongs = decoded
        } catch {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
}
