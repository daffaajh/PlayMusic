import SwiftUI

@main
struct PlayMusicApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        }
    }
}
