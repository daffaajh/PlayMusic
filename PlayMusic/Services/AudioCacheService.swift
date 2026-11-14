import Foundation

final class AudioCacheService {
    static let shared = AudioCacheService()
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("AudioTracks", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    func cachedFileURL(for id: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent("\(id).m4a")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func saveToCache(remoteURL: URL, for id: String) {
        let destinationURL = cacheDirectory.appendingPathComponent("\(id).m4a")
        guard !fileManager.fileExists(atPath: destinationURL.path) else { return }
        
        Task.detached(priority: .background) {
            do {
                let (tempURL, response) = try await URLSession.shared.download(from: remoteURL)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try? FileManager.default.removeItem(at: destinationURL)
                }
                try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
            } catch {
                // Silently skip if download or cache fails
            }
        }
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
    }
}
