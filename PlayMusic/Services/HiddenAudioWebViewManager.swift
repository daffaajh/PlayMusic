import SwiftUI
import WebKit
import MediaPlayer

final class HiddenAudioWebViewManager: NSObject, ObservableObject, WKScriptMessageHandler, WKNavigationDelegate {
    static let shared = HiddenAudioWebViewManager()
    
    private var webView: WKWebView?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    
    override init() {
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let controller = WKUserContentController()
        controller.add(self, name: "playbackUpdate")
        config.userContentController = controller
        
        DispatchQueue.main.async {
            self.webView = WKWebView(frame: .zero, configuration: config)
            self.webView?.navigationDelegate = self
        }
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
            <style>body { margin: 0; background: transparent; }</style>
        </head>
        <body>
            <div id="player"></div>
            <script src="https://www.youtube.com/iframe_api"></script>
            <script>
                var player;
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        height: '100',
                        width: '100',
                        videoId: '\(videoId)',
                        playerVars: {
                            'autoplay': 1,
                            'playsinline': 1,
                            'controls': 0,
                            'disablekb': 1,
                            'fs': 0,
                            'origin': 'https://music.youtube.com'
                        },
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange': onPlayerStateChange
                        }
                    });
                }
                function onPlayerReady(event) {
                    event.target.playVideo();
                    setInterval(updateProgress, 350);
                }
                function onPlayerStateChange(event) {
                    window.webkit.messageHandlers.playbackUpdate.postMessage({
                        state: event.data,
                        currentTime: player.getCurrentTime() || 0,
                        duration: player.getDuration() || 1
                    });
                }
                function updateProgress() {
                    if (player && player.getPlayerState() === 1) {
                        window.webkit.messageHandlers.playbackUpdate.postMessage({
                            state: 1,
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
            self.webView?.loadHTMLString(html, baseURL: URL(string: "https://music.youtube.com"))
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
