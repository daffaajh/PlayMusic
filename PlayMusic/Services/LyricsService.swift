import Foundation

final class LyricsService {
    static let shared = LyricsService()
    private let session = URLSession.shared
    
    func fetchLyrics(title: String, artist: String, duration: Int? = nil) async -> LyricData? {
        var components = URLComponents(string: "https://lrclib.net/api/get")
        var queryItems = [
            URLQueryItem(name: "track_name", value: title),
            URLQueryItem(name: "artist_name", value: artist)
        ]
        if let duration = duration {
            queryItems.append(URLQueryItem(name: "duration", value: String(duration)))
        }
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            
            if let syncedLyrics = json["syncedLyrics"] as? String, !syncedLyrics.isEmpty {
                let lines = parseLRC(syncedLyrics)
                return LyricData(isSynced: true, lines: lines, rawText: syncedLyrics)
            }
            
            if let plainLyrics = json["plainLyrics"] as? String, !plainLyrics.isEmpty {
                return LyricData(isSynced: false, lines: [], rawText: plainLyrics)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let pattern = "\\[(\\d{2}):(\\d{2})\\.(\\d{2,3})\\](.*)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        for rawLine in lrc.components(separatedBy: .newlines) {
            let nsLine = rawLine as NSString
            let matches = regex.matches(in: rawLine, range: NSRange(location: 0, length: nsLine.length))
            
            for match in matches where match.numberOfRanges == 5 {
                let minStr = nsLine.substring(with: match.range(at: 1))
                let secStr = nsLine.substring(with: match.range(at: 2))
                let msStr = nsLine.substring(with: match.range(at: 3))
                let text = nsLine.substring(with: match.range(at: 4)).trimmingCharacters(in: .whitespaces)
                
                let minutes = Int(minStr) ?? 0
                let seconds = Int(secStr) ?? 0
                let ms = (Int(msStr) ?? 0) * (msStr.count == 2 ? 10 : 1)
                let totalMs = (minutes * 60 + seconds) * 1000 + ms
                
                if !text.isEmpty {
                    lines.append(LyricLine(timestampMs: totalMs, text: text))
                }
            }
        }
        
        return lines.sorted { $0.timestampMs < $1.timestampMs }
    }
}
