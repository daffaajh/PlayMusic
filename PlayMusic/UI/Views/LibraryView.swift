import SwiftUI

struct LibraryView: View {
    @ObservedObject var favorites = FavoritesManager.shared
    @ObservedObject var player = AudioPlayerManager.shared

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Library")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                if favorites.favoriteSongs.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "heart.slash")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No Favorite Songs Yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Tap the heart icon on any song to add it here.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.7))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        Text("Favorite Songs (\(favorites.favoriteSongs.count))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        ForEach(favorites.favoriteSongs) { song in
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
                }
            }
        }
    }
}
