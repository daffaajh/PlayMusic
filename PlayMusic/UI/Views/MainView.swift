import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var showFullPlayer: Bool = false
    @ObservedObject var player = AudioPlayerManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Web Audio Engine Host (attached to window tree)
            BackgroundWebAudioView()
                .frame(width: 1, height: 1)
                .opacity(0.01)

            ZStack {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    SearchView()
                case 2:
                    LibraryView()
                case 3:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 8) {
                if player.currentSong != nil {
                    MiniPlayerView(showFullPlayer: $showFullPlayer)
                }

                floatingTabBar
            }
            .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showFullPlayer) {
            FullPlayerView()
        }
    }

    private var floatingTabBar: some View {
        HStack(spacing: 36) {
            tabButton(icon: "music.note.house.fill", title: "Beranda", tabIndex: 0)
            tabButton(icon: "magnifyingglass", title: "Cari", tabIndex: 1)
            tabButton(icon: "heart.fill", title: "Koleksi", tabIndex: 2)
            tabButton(icon: "gearshape.fill", title: "Setelan", tabIndex: 3)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 32, allowsDragPhysics: true)
        .padding(.horizontal, 24)
    }

    private func tabButton(icon: String, title: String, tabIndex: Int) -> some View {
        Button(action: {
            selectedTab = tabIndex
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: selectedTab == tabIndex ? .bold : .medium))
                Text(title)
                    .font(.system(size: 10, weight: selectedTab == tabIndex ? .bold : .medium, design: .rounded))
            }
            .foregroundColor(selectedTab == tabIndex ? .primary : .secondary.opacity(0.5))
            .scaleEffect(selectedTab == tabIndex ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
        }
    }
}
