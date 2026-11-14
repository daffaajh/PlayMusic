import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let durationSeconds: Int?
    let thumbnailURL: String?
    
    var highResThumbnail: URL? {
        guard let thumbnailURL = thumbnailURL else { return nil }
        let highRes = thumbnailURL
            .replacingOccurrences(of: "w120-h120", with: "w600-h600")
            .replacingOccurrences(of: "w60-h60", with: "w600-h600")
        return URL(string: highRes)
    }
}

struct LyricLine: Identifiable, Equatable {
    let id = UUID()
    let timestampMs: Int
    let text: String
}

struct LyricData {
    let isSynced: Bool
    let lines: [LyricLine]
    let rawText: String?
}
