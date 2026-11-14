import SwiftUI
import AVKit

struct AirPlayButtonView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = colorScheme == .light ? .label : .white
        picker.activeTintColor = .systemBlue
        picker.backgroundColor = .clear
        picker.prioritizesVideoDevices = false
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = colorScheme == .light ? .label : .white
    }
}
