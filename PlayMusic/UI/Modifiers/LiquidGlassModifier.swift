import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    var cornerRadius: CGFloat = 30
    var allowsDragPhysics: Bool = true

    func body(content: Content) -> some View {
        let stretchX = 1.0 + (abs(dragOffset.width) * 0.0008) - (abs(dragOffset.height) * 0.0004)
        let stretchY = 1.0 + (abs(dragOffset.height) * 0.0008) - (abs(dragOffset.width) * 0.0004)
        let isLight = colorScheme == .light
        
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isLight ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.ultraThinMaterial))
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    isLight ? Color.white.opacity(0.7) : Color.white.opacity(0.35),
                                    isLight ? Color.black.opacity(0.04) : Color.white.opacity(0.08),
                                    isLight ? Color.white.opacity(0.4) : Color.white.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: isLight ? Color.black.opacity(isDragging ? 0.18 : 0.08) : Color.black.opacity(isDragging ? 0.45 : 0.25),
                radius: isDragging ? 24 : 12,
                x: 0,
                y: isDragging ? 14 : 6
            )
            .scaleEffect(x: max(0.85, min(1.25, stretchX)), y: max(0.85, min(1.25, stretchY)))
            .offset(x: dragOffset.width * 0.45, y: dragOffset.height * 0.45)
            .simultaneousGesture(
                allowsDragPhysics ?
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        if !isDragging {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        isDragging = true
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.interpolatingSpring(stiffness: 280, damping: 14)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                : nil
            )
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 30, allowsDragPhysics: Bool = true) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, allowsDragPhysics: allowsDragPhysics))
    }
}
