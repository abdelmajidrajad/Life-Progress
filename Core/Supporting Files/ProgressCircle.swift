import SwiftUI
public struct ProgressCircle: View {
    let color: Color
    let lineWidth: CGFloat
    let labelHidden: Bool
    @Binding var progress: NSNumber
    
    public init(
        color: Color,
        lineWidth: CGFloat = 5.0,
        labelHidden: Bool = false,
        progress: Binding<NSNumber>
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.labelHidden = labelHidden
        self._progress = progress
    }
        
    public var body: some View {
        ZStack {
            Circle()
                .trim(from: .zero, to: CGFloat(progress.doubleValue))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                       ),
                    style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                ))
                .rotationEffect(Angle(degrees: -90))
                .background(
                    Circle()
                        .stroke(color.opacity(0.1), style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        ))
                        .rotationEffect(Angle(degrees: -90))
                )
                .aspectRatio(contentMode: .fit)
                .padding(4.0)
            
            if !labelHidden {
                Text(percentFormatter().string(from: progress) ?? "\(progress)")
                    .font(.preferred(.py_footnote()))
            }
        }
    }
}

