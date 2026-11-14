import SwiftUI

struct QueueSheetView: View {
    @ObservedObject var player = AudioPlayerManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Header Sheet
                HStack {
                    Text("Berikutnya")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Spacer()

                    Button("Selesai") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if player.queue.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .font(.system(size: 42))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Antrean Kosong")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("Pilih lagu di beranda untuk ditambahkan ke antrean.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.7))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(Array(player.queue.enumerated()), id: \.element.id) { index, song in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)

                                AsyncImage(url: song.highResThumbnail) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Color.secondary.opacity(0.15)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(song.artist)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Button(action: {
                                    player.queue.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                player.play(song: song)
                                player.queue.remove(at: index)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}
