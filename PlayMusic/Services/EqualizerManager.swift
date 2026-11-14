import Foundation

enum AudioEqualizerPreset: String, CaseIterable, Identifiable {
    case flat = "Flat"
    case bassBooster = "Bass Booster"
    case vocal = "Vocal Booster"
    case acoustic = "Akustik"
    case electronic = "Elektronik"
    case treble = "Treble Booster"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .flat: return "Suara natural dan seimbang tanpa distorsi frekuensi."
        case .bassBooster: return "Meningkatkan dentuman bass rendah (60Hz - 250Hz)."
        case .vocal: return "Memperjelas vokal dan lirik di frekuensi menengah (1kHz - 3kHz)."
        case .acoustic: return "Optimal untuk petikan gitar dan musik akustik hangat."
        case .electronic: return "Mengangkat bass dan high-end untuk musik EDM / Beat."
        case .treble: return "Menonjolkan detail suara instrumen tinggi dan simbal."
        }
    }
}

final class EqualizerManager: ObservableObject {
    static let shared = EqualizerManager()
    private let presetKey = "selected_eq_preset"

    @Published var selectedPreset: AudioEqualizerPreset = .flat {
        didSet {
            UserDefaults.standard.set(selectedPreset.rawValue, forKey: presetKey)
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: presetKey),
           let preset = AudioEqualizerPreset(rawValue: saved) {
            self.selectedPreset = preset
        }
    }
}
