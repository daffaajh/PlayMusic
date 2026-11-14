import SwiftUI
import WebKit
import MediaPlayer

final class HiddenAudioWebViewManager: NSObject, ObservableObject, WKScriptMessageHandler, WKNavigationDelegate {
    static let shared = HiddenAudioWebViewManager()
    
    private var webView: WKWebView!
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    
    override init() {
        super.init()
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let controller = WKUserContentController()
        config.userContentController = controller
        
        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 2, height: 2), configuration: config)
        controller.add(self, name: "playbackUpdate")
        self.webView.navigationDelegate = self
    }

    func getWebView() -> WKWebView {
        return self.webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        
        DispatchQueue.main.async {
            if let state = body["state"] as? Int {
                // 1 = playing, 2 = paused
                self.isPlaying = (state == 1)
                AudioPlayerManager.shared.isPlaying = self.isPlaying
            }
            if let curr = body["currentTime"] as? Double {
                self.currentTime = curr
                AudioPlayerManager.shared.currentTime = curr
            }
            if let dur = body["duration"] as? Double, dur > 0 {
                self.duration = dur
                AudioPlayerManager.shared.duration = dur
            }
        }
    }
    
    func loadAndPlay(videoId: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>body { margin: 0; background: black; }</style>
        </head>
        <body>
            <iframe id="player" width="100%" height="100%" 
                    src="https://www.youtube-nocookie.com/embed/\(videoId)?enablejsapi=1&autoplay=1&playsinline=1&controls=0&origin=https://www.youtube-nocookie.com" 
                    frameborder="0" allow="autoplay; encrypted-media">
            </iframe>
            <script>
                var tag = document.createElement('script');
                tag.src = "https://www.youtube.com/iframe_api";
                var firstScriptTag = document.getElementsByTagName('script')[0];
                firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

                var player;
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange': onPlayerStateChange
                        }
                    });
                }
                function onPlayerReady(event) {
                    event.target.playVideo();
                    setInterval(updateProgress, 300);
                }
                function onPlayerStateChange(event) {
                    window.webkit.messageHandlers.playbackUpdate.postMessage({
                        state: event.data,
                        currentTime: player.getCurrentTime() || 0,
                        duration: player.getDuration() || 1
                    });
                }
                function updateProgress() {
                    if (player && typeof player.getCurrentTime === 'function') {
                        window.webkit.messageHandlers.playbackUpdate.postMessage({
                            state: player.getPlayerState(),
                            currentTime: player.getCurrentTime() || 0,
                            duration: player.getDuration() || 1
                        });
                    }
                }
            </script>
        </body>
        </html>
        """
        DispatchQueue.main.async {
            self.webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
        }
    }
    
    func togglePlayPause() {
        let script = isPlaying ? "player.pauseVideo();" : "player.playVideo();"
        webView?.evaluateJavaScript(script, completionHandler: nil)
        isPlaying.toggle()
        AudioPlayerManager.shared.isPlaying = isPlaying
    }
    
    func seek(to seconds: Double) {
        webView?.evaluateJavaScript("player.seekTo(\(seconds), true);", completionHandler: nil)
        currentTime = seconds
        AudioPlayerManager.shared.currentTime = seconds
    }
}
