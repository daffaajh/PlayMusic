import SwiftUI

struct UnsupportedOSView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.yellow)

                Text("Perangkat Tidak Memenuhi Syarat")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("PlayMusic membutuhkan minimal iOS 15.0 untuk dapat dijalankan secara optimal.\n\nVersi iOS perangkat Anda saat ini: \(UIDevice.current.systemVersion). Silakan perbarui versi iOS Anda.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
        }
    }
}
