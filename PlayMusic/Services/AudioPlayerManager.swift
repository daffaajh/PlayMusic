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
    
    private var originalQueue: [Song] = []
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: Any?
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
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
        if repeatMode == .one, let song = currentSong {
            seek(to: 0)
            player?.play()
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
                self.player?.pause()
                self.isPlaying = false
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.player?.play()
                        self.isPlaying = true
                    }
                }
            @unknown default:
                break
            }
        }
    }
    
    func play(song: Song) {
        self.currentSong = song
        self.isPlaying = false
        self.currentTime = 0
        self.lyrics = nil
        self.currentLyricIndex = nil
        
        if let localURL = AudioCacheService.shared.cachedFileURL(for: song.id) {
            startPlayback(url: localURL, song: song)
            Task {
                self.lyrics = await LyricsService.shared.fetchLyrics(title: song.title, artist: song.artist)
            }
            return
        }
        
        Task {
            async let streamURLTask = InnertubeService.shared.getStreamURL(videoId: song.id)
            async let lyricsTask = LyricsService.shared.fetchLyrics(title: song.title, artist: song.artist)
            
            do {
                let streamURL = try await streamURLTask
                startPlayback(url: streamURL, song: song)
                AudioCacheService.shared.saveToCache(remoteURL: streamURL, for: song.id)
            } catch {
                print("Failed to get stream: \(error)")
            }
            
            self.lyrics = await lyricsTask
        }
    }
    
    private func startPlayback(url: URL, song: Song) {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
        
        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.playNextInQueue()
        }
        
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let dur = self.player?.currentItem?.duration.seconds, !dur.isNaN && dur > 0 {
                self.duration = dur
            }
            self.updateActiveLyric()
            self.updateNowPlayingCenter()
        }
        
        player?.play()
        self.isPlaying = true
        setupNowPlayingInfo(song: song)
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updateNowPlayingCenter()
    }
    
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
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
