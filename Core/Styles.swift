import SwiftUI
public struct CloseButtonCircleStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1: 1.0)
            .padding()
            .font(.headline)
            .foregroundColor(Color(.secondaryLabel))
            .background(
                VisualEffectBlur(blurStyle: .extraLight)
                    .clipShape(Circle())
            )

    }
}
