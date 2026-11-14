import SwiftUI

@main
struct PlayMusicApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            if #available(iOS 15.0, *) {
                MainView()
                    .preferredColorScheme(themeManager.selectedTheme.colorScheme)
            } else {
                UnsupportedOSView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
