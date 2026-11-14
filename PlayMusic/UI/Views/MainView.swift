import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var showFullPlayer: Bool = false
    @ObservedObject var player = AudioPlayerManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                HomeView()
                    .tag(1)
                
                LibraryView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

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
        HStack(spacing: 40) {
            tabButton(icon: "house.fill", title: "Home", tabIndex: 0)
            tabButton(icon: "magnifyingglass", title: "Search", tabIndex: 1)
            tabButton(icon: "music.note.list", title: "Library", tabIndex: 2)
            tabButton(icon: "gearshape.fill", title: "Settings", tabIndex: 3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .liquidGlass(cornerRadius: 32, allowsDragPhysics: true)
        .padding(.horizontal, 20)
    }

    private func tabButton(icon: String, title: String, tabIndex: Int) -> some View {
        Button(action: {
            selectedTab = tabIndex
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == tabIndex ? .primary : .secondary.opacity(0.6))
        }
    }
}
