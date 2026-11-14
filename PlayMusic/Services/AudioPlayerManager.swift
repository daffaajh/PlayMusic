import Foundation
import AVFoundation
import MediaPlayer

enum RepeatMode: String {
    case off
    case all
    case one
}

@MainActor
final class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var lyrics: LyricData?
    @Published var currentLyricIndex: Int?
    @Published var queue: [Song] = []
    @Published var repeatMode: RepeatMode = .off
    @Published var isShuffle: Bool = false
    
    // Crossfade & Automix State
    @Published var crossfadeDuration: Double = 4.0 // 0 to 12 seconds
    @Published var isAutomixEnabled: Bool = true
    
    private var originalQueue: [Song] = []
    private var activePlayer: AVPlayer?
    private var secondaryPlayer: AVPlayer?
    private var isUsingPrimaryPlayer: Bool = true
    
    private var timeObserver: Any?
    private var isTransitioning: Bool = false
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
        
        let savedCrossfade = UserDefaults.standard.double(forKey: "crossfade_seconds")
        if savedCrossfade > 0 {
            self.crossfadeDuration = savedCrossfade
        }
        if UserDefaults.standard.object(forKey: "automix_enabled") != nil {
            self.isAutomixEnabled = UserDefaults.standard.bool(forKey: "automix_enabled")
        }
    }

    func playNextTrack() {
        guard !queue.isEmpty else { return }
        let nextSong = queue.removeFirst()
        play(song: nextSong)
    }

    func playPreviousTrack() {
        if currentTime > 3 {
            seek(to: 0)
        } else {
            seek(to: 0)
        }
    }

    func addToQueue(_ song: Song) {
        queue.append(song)
        originalQueue.append(song)
    }

    func playNext(_ song: Song) {
        queue.insert(song, at: 0)
        originalQueue.insert(song, at: 0)
    }

    func toggleShuffle() {
        isShuffle.toggle()
        if isShuffle {
            queue.shuffle()
        } else {
            queue = originalQueue
        }
    }

    func toggleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    func playNextInQueue() {
        if repeatMode == .one, currentSong != nil {
            seek(to: 0)
            activePlayer?.play()
            isPlaying = true
            return
        }
        
        guard !queue.isEmpty else {
            if repeatMode == .all && !originalQueue.isEmpty {
                queue = isShuffle ? originalQueue.shuffled() : originalQueue
                let nextSong = queue.removeFirst()
                play(song: nextSong)
            }
            return
        }
        let nextSong = queue.removeFirst()
        play(song: nextSong)
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
        }
        
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
            
            switch type {
            case .began:
                self.activePlayer?.pause()
                self.isPlaying = false
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.activePlayer?.play()
                        self.isPlaying = true
                    }
                }
            @unknown default:
                break
            }
        }
    }
    
    func play(song: Song) {
        // Mencegah lagu berhenti dan mulai dari ulang jika user menekan lagu yang sama
        if let current = self.currentSong, current.id == song.id {
            if !isPlaying {
                togglePlayPause()
            }
            return
        }

        self.currentSong = song
        self.isPlaying = false
        self.currentTime = 0
        self.lyrics = nil
        self.currentLyricIndex = nil
        
        HiddenAudioWebViewManager.shared.loadAndPlay(videoId: song.id)
        self.isPlaying = true
        setupNowPlayingInfo(song: song)
        
        Task {
            self.lyrics = await LyricsService.shared.fetchLyrics(title: song.title, artist: song.artist)
        }
    }
    
    func togglePlayPause() {
        HiddenAudioWebViewManager.shared.togglePlayPause()
        self.isPlaying = HiddenAudioWebViewManager.shared.isPlaying
        updateNowPlayingCenter()
    }
    
    func seek(to seconds: Double) {
        HiddenAudioWebViewManager.shared.seek(to: seconds)
        self.currentTime = seconds
        updateActiveLyric()
        updateNowPlayingCenter()
    }
    
    private func startPlayback(url: URL, song: Song, isCrossfadeTransition: Bool = false) {
        if let observer = timeObserver {
            activePlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        let newItem = AVPlayerItem(url: url)
        let nextPlayer = AVPlayer(playerItem: newItem)
        
        if isCrossfadeTransition && crossfadeDuration > 0, let currentPlayer = activePlayer {
            // Apple Music Automix: Curve EQ beat-matching fade (Equal-Power Crossfade)
            // Menggunakan fungsi sinus/kosinus agar energi suara konstan, tidak drop di tengah transisi
            nextPlayer.volume = 0.0
            nextPlayer.play()
            
            let steps = 30
            let interval = crossfadeDuration / Double(steps)
            
            for step in 1...steps {
                let t = Double(step) / Double(steps) // 0.0 -> 1.0
                let outVol = Float(cos(t * .pi / 2)) // Equal power out
                let inVol = Float(sin(t * .pi / 2))  // Equal power in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(step))) { [weak currentPlayer, weak nextPlayer] in
                    currentPlayer?.volume = outVol
                    nextPlayer?.volume = inVol
                    
                    if step == steps {
                        currentPlayer?.pause()
                    }
                }
            }
            
            activePlayer = nextPlayer
        } else {
            activePlayer?.pause()
            nextPlayer.volume = 1.0
            nextPlayer.play()
            activePlayer = nextPlayer
        }
        
        isTransitioning = false
        
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = activePlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let dur = self.activePlayer?.currentItem?.duration.seconds, !dur.isNaN && dur > 0 {
                self.duration = dur
            }
            self.updateActiveLyric()
            self.updateNowPlayingCenter()
            
            // Automix Trigger
            let remainingTime = self.duration - self.currentTime
            let triggerThreshold = self.crossfadeDuration > 0 ? self.crossfadeDuration : 0.8
            
            if remainingTime <= triggerThreshold && !self.isTransitioning && !self.queue.isEmpty {
                self.isTransitioning = true
                self.triggerNextTrackWithTransition()
            } else if remainingTime <= 0.3 && !self.isTransitioning && self.queue.isEmpty {
                self.playNextInQueue()
            }
        }
        
        self.isPlaying = true
        setupNowPlayingInfo(song: song)
    }

    private func triggerNextTrackWithTransition() {
        guard !queue.isEmpty else { return }
        let nextSong = queue.removeFirst()
        self.currentSong = nextSong
        self.lyrics = nil
        self.currentLyricIndex = nil
        
        if let localURL = AudioCacheService.shared.cachedFileURL(for: nextSong.id) {
            startPlayback(url: localURL, song: nextSong, isCrossfadeTransition: true)
            Task {
                self.lyrics = await LyricsService.shared.fetchLyrics(title: nextSong.title, artist: nextSong.artist)
            }
            return
        }
        
        Task {
            async let streamURLTask = InnertubeService.shared.getStreamURL(videoId: nextSong.id)
            async let lyricsTask = LyricsService.shared.fetchLyrics(title: nextSong.title, artist: nextSong.artist)
            
            do {
                let streamURL = try await streamURLTask
                startPlayback(url: streamURL, song: nextSong, isCrossfadeTransition: true)
                AudioCacheService.shared.saveToCache(remoteURL: streamURL, for: nextSong.id)
            } catch {
                print("Failed to stream next song in automix: \(error)")
            }
            self.lyrics = await lyricsTask
        }
    }
    
    private func updateActiveLyric() {
        guard let lyrics = lyrics, lyrics.isSynced else { return }
        let currentMs = Int(currentTime * 1000)
        
        if let idx = lyrics.lines.lastIndex(where: { $0.timestampMs <= currentMs }) {
            if currentLyricIndex != idx {
                currentLyricIndex = idx
            }
        }
    }
    
    private func setupNowPlayingInfo(song: Song) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = song.title
        info[MPMediaItemPropertyArtist] = song.artist
        if let album = song.album {
            info[MPMediaItemPropertyAlbumTitle] = album
        }
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        guard let thumbURL = song.highResThumbnail else { return }
        Task.detached(priority: .background) {
            do {
                let (data, _) = try await URLSession.shared.data(from: thumbURL)
                if let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    await MainActor.run {
                        guard var currentInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
                        currentInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = currentInfo
                    }
                }
            } catch {
                // Silently ignore artwork fetch error
            }
        }
    }
    
    private func updateNowPlayingCenter() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }
}
