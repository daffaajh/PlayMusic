import Foundation
import Combine

final class SleepTimerManager: ObservableObject {
    static let shared = SleepTimerManager()
    
    @Published var isTimerActive: Bool = false
    @Published var remainingSeconds: Int = 0
    
    private var timer: Timer?
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer(minutes: Int) {
        cancelTimer()
        remainingSeconds = minutes * 60
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.triggerSleep()
            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        remainingSeconds = 0
    }
    
    private func triggerSleep() {
        cancelTimer()
        Task { @MainActor in
            if AudioPlayerManager.shared.isPlaying {
                AudioPlayerManager.shared.togglePlayPause()
            }
        }
    }
}
