import Foundation

final class SleepTimerManager: ObservableObject {
    static let shared = SleepTimerManager()
    
    @Published var timeRemaining: Int = 0
    @Published var isTimerActive: Bool = false
    
    private var timer: Timer?

    func startTimer(minutes: Int) {
        cancelTimer()
        timeRemaining = minutes * 60
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.cancelTimer()
                Task { @MainActor in
                    if AudioPlayerManager.shared.isPlaying {
                        AudioPlayerManager.shared.togglePlayPause()
                    }
                }
            }
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
        isTimerActive = false
    }

    var formattedTime: String {
        let min = timeRemaining / 60
        let sec = timeRemaining % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
