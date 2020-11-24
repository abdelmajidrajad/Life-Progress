import SwiftUI
import UIKit
public struct HDashedLine: View {
    let color: Color
    let lineWidth: CGFloat
    public init(color: Color = Color(.secondaryLabel),
                lineWidth: CGFloat = 1) {
        self.color = color
        self.lineWidth = lineWidth
    }
    public var body: some View {
        GeometryReader { proxy in
            Path { path in
                let maxX = proxy.size.width
                path.move(to: .zero)
                path.addLine(to: CGPoint.init(x: maxX, y: 0))
            }.stroke(style:
                        StrokeStyle(
                            lineWidth: self.lineWidth,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [5]
                        )
            ).foregroundColor(self.color)
        }.frame(height: lineWidth)
    }
}
