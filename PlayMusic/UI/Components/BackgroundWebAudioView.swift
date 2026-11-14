import SwiftUI
import WebKit

struct BackgroundWebAudioView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return HiddenAudioWebViewManager.shared.getWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
