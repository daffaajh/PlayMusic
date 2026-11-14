import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case parseError
    case streamNotFound
}

final class InnertubeService {
    static let shared = InnertubeService()
    private let session = URLSession.shared
    
    private let baseURL = "https://music.youtube.com/youtubei/v1"
    private let clientContext: [String: Any] = [
        "client": [
            "clientName": "WEB_REMIX",
            "clientVersion": "1.20231204.01.00",
            "hl": "en",
            "gl": "US"
        ]
    ]
    
    private func post(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Referer")
        
        var mergedBody = body
        mergedBody["context"] = clientContext
        
        request.httpBody = try JSONSerialization.data(withJSONObject: mergedBody)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.parseError
        }
        
        return json
    }
    
    func getTrending() async throws -> [Song] {
        return try await search(query: "Top Indonesian and Global Hits")
    }

    func search(query: String) async throws -> [Song] {
        let json = try await post(endpoint: "search", body: [
            "query": query,
            "params": "Eg-KAQwIARAAGAAgACgAMABqChAEEAMQCRAFEAo%3D"
        ])
        
        var songs: [Song] = []
        guard let contents = json["contents"] as? [String: Any],
              let sectionList = contents["sectionListRenderer"] as? [String: Any],
              let subContents = sectionList["contents"] as? [[String: Any]] else {
            return []
        }
        
        for item in subContents {
            guard let shelf = (item["musicShelfRenderer"] ?? item["musicCardShelfRenderer"]) as? [String: Any],
                  let shelfContents = shelf["contents"] as? [[String: Any]] else { continue }
            
            for content in shelfContents {
                guard let itemRenderer = content["musicResponsiveListItemRenderer"] as? [String: Any] else { continue }
                if let song = parseSongItem(itemRenderer) {
                    songs.append(song)
                }
            }
        }
        
        return songs
    }
    
    private func parseSongItem(_ item: [String: Any]) -> Song? {
        guard let flexColumns = item["flexColumns"] as? [[String: Any]],
              flexColumns.count >= 2 else { return nil }
        
        let titleColumn = flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any]
        let titleRuns = (titleColumn?["text"] as? [String: Any])?["runs"] as? [[String: Any]]
        let title = titleRuns?.first?["text"] as? String ?? "Unknown Title"
        
        let artistColumn = flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any]
        let artistRuns = (artistColumn?["text"] as? [String: Any])?["runs"] as? [[String: Any]]
        let artist = artistRuns?.first?["text"] as? String ?? "Unknown Artist"
        let album = artistRuns?.count ?? 0 > 2 ? artistRuns?[2]["text"] as? String : nil
        
        let navEndpoint = titleRuns?.first?["navigationEndpoint"] as? [String: Any]
        let watchEndpoint = navEndpoint?["watchEndpoint"] as? [String: Any]
        let videoId = watchEndpoint?["videoId"] as? String ?? (item["playlistItemData"] as? [String: Any])?["videoId"] as? String
        
        guard let id = videoId else { return nil }
        
        var thumbURL: String?
        if let thumbRenderer = (item["thumbnail"] as? [String: Any])?["musicThumbnailRenderer"] as? [String: Any],
           let thumbnails = (thumbRenderer["thumbnail"] as? [String: Any])?["thumbnails"] as? [[String: Any]] {
            thumbURL = thumbnails.last?["url"] as? String
        }
        
        return Song(id: id, title: title, artist: artist, album: album, durationSeconds: nil, thumbnailURL: thumbURL)
    }
    
    func getStreamURL(videoId: String) async throws -> URL {
        // 1. Coba Android Music Client (Paling stabil tanpa signature cipher)
        if let url = try? await fetchStreamWithClient(videoId: videoId, clientName: "ANDROID_MUSIC", clientVersion: "6.20.51") {
            return url
        }
        
        // 2. Coba iOS Client
        if let url = try? await fetchStreamWithClient(videoId: videoId, clientName: "IOS", clientVersion: "19.09.3") {
            return url
        }

        // 3. Coba Web Remix
        if let url = try? await fetchStreamWithClient(videoId: videoId, clientName: "WEB_REMIX", clientVersion: "1.20231204.01.00") {
            return url
        }

        // 4. Fallback Piped / Invidious API (Bypass age-restriction & bot-detection 100% tanpa login)
        if let url = try? await fetchFromPipedFallback(videoId: videoId) {
            return url
        }
        
        throw NetworkError.streamNotFound
    }
    
    private func fetchFromPipedFallback(videoId: String) async throws -> URL {
        let instances = [
            "https://pipedapi.kavin.rocks",
            "https://api.piped.privacydev.net",
            "https://piped-api.lunar.icu"
        ]
        
        for instance in instances {
            guard let url = URL(string: "\(instance)/streams/\(videoId)") else { continue }
            do {
                let (data, response) = try await session.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let audioStreams = json["audioStreams"] as? [[String: Any]] else {
                    continue
                }
                
                let sorted = audioStreams.sorted { ($0["bitrate"] as? Int ?? 0) > ($1["bitrate"] as? Int ?? 0) }
                if let streamURLString = sorted.first?["url"] as? String, let streamURL = URL(string: streamURLString) {
                    return streamURL
                }
            } catch {
                continue
            }
        }
        
        throw NetworkError.streamNotFound
    }
    
    private func fetchStreamWithClient(videoId: String, clientName: String, clientVersion: String) async throws -> URL {
        let playerPayload: [String: Any] = [
            "videoId": videoId,
            "context": [
                "client": [
                    "clientName": clientName,
                    "clientVersion": clientVersion,
                    "hl": "en",
                    "gl": "US"
                ]
            ]
        ]
        
        let json = try await post(endpoint: "player", body: playerPayload)
        
        guard let streamingData = json["streamingData"] as? [String: Any] else {
            throw NetworkError.streamNotFound
        }
        
        var audioFormats = (streamingData["adaptiveFormats"] as? [[String: Any]]) ?? []
        audioFormats = audioFormats.filter { ($0["mimeType"] as? String)?.contains("audio/") == true }
        
        audioFormats.sort { ($0["bitrate"] as? Int ?? 0) > ($1["bitrate"] as? Int ?? 0) }
        
        for format in audioFormats {
            let quality = UserDefaults.standard.string(forKey: "audio_quality_preference") ?? "High"
            let targetBitrate = quality == "Low" ? 70000 : (quality == "Normal" ? 130000 : 256000)
            
            if quality != "High", let bitrate = format["bitrate"] as? Int, bitrate > targetBitrate {
                continue
            }
            if let directURLString = format["url"] as? String, let directURL = URL(string: directURLString) {
                return directURL
            }
        }
        
        if let fallbackURLString = audioFormats.first?["url"] as? String, let fallbackURL = URL(string: fallbackURLString) {
            return fallbackURL
        }
        
        throw NetworkError.streamNotFound
    }
}
