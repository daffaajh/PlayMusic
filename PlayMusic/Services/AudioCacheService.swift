import Foundation

final class AudioCacheService: ObservableObject {
    static let shared = AudioCacheService()
    private let fileManager = FileManager.default
    private let downloadedSongsKey = "downloaded_songs_metadata_v1"
    
    @Published var downloadedSongs: [Song] = []
    @Published var activeDownloads: Set<String> = []
    
    private var downloadTasks: [String: Task<Void, Never>] = [:]
    
    private init() {
        loadDownloadedSongs()
    }
    
    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("AudioTracks", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    /// Sanitizes the video ID into a safe alphanumeric string to prevent directory traversal
    private func safeId(_ id: String) -> String {
        let safe = id.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_")).inverted).joined()
        return safe.isEmpty ? "track_\(abs(id.hashValue))" : safe
    }
    
    func cachedFileURL(for id: String) -> URL? {
        let safe = safeId(id)
        let fileURL = cacheDirectory.appendingPathComponent("\(safe).m4a")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func isDownloaded(id: String) -> Bool {
        return cachedFileURL(for: id) != nil
    }
    
    func saveToCache(remoteURL: URL, for song: Song) {
        let id = song.id
        guard cachedFileURL(for: id) == nil else { return }
        guard downloadTasks[id] == nil else { return }
        
        let destinationURL = cacheDirectory.appendingPathComponent("\(safeId(id)).m4a")
        
        let task = Task.detached(priority: .background) { [weak self] in
            do {
                let (tempURL, response) = try await URLSession.shared.download(from: remoteURL)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try? FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                
                await MainActor.run {
                    self?.addDownloadedSong(song)
                    self?.downloadTasks.removeValue(forKey: id)
                }
            } catch {
                await MainActor.run {
                    self?.downloadTasks.removeValue(forKey: id)
                }
            }
        }
        
        downloadTasks[id] = task
    }
    
    func downloadExplicitly(song: Song, remoteURL: URL) async throws {
        let id = song.id
        let destinationURL = cacheDirectory.appendingPathComponent("\(safeId(id)).m4a")
        
        await MainActor.run {
            self.activeDownloads.insert(id)
        }
        
        defer {
            Task { @MainActor in
                self.activeDownloads.remove(id)
            }
        }
        
        let (tempURL, response) = try await URLSession.shared.download(from: remoteURL)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }
        try fileManager.moveItem(at: tempURL, to: destinationURL)
        
        await MainActor.run {
            self.addDownloadedSong(song)
        }
    }
    
    func removeDownload(id: String) {
        if let fileURL = cachedFileURL(for: id) {
            try? fileManager.removeItem(at: fileURL)
        }
        downloadedSongs.removeAll { $0.id == id }
        saveDownloadedMetadata()
    }
    
    private func addDownloadedSong(_ song: Song) {
        if !downloadedSongs.contains(where: { $0.id == song.id }) {
            downloadedSongs.insert(song, at: 0)
            saveDownloadedMetadata()
        }
    }
    
    private func saveDownloadedMetadata() {
        if let data = try? JSONEncoder().encode(downloadedSongs) {
            UserDefaults.standard.set(data, forKey: downloadedSongsKey)
        }
    }
    
    private func loadDownloadedSongs() {
        if let data = UserDefaults.standard.data(forKey: downloadedSongsKey),
           let songs = try? JSONDecoder().decode([Song].self, from: data) {
            // Verify files actually exist on disk
            self.downloadedSongs = songs.filter { cachedFileURL(for: $0.id) != nil }
        }
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        downloadedSongs.removeAll()
        saveDownloadedMetadata()
    }
    
    func getCacheSizeString() -> String {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 MB"
        }
        var totalBytes: Int64 = 0
        for file in contents {
            if let attrs = try? fileManager.attributesOfItem(atPath: file.path),
               let size = attrs[.size] as? Int64 {
                totalBytes += size
            }
        }
        let mb = Double(totalBytes) / (1024 * 1024)
        return String(format: "%.1f MB", mb)
    }
}
