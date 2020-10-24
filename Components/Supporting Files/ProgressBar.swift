import SwiftUI
public struct ProgressBar: View {
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
        GeometryReader { proxy in
            VStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6.0)
                        .fill(color.opacity(0.2))
                    RoundedRectangle(cornerRadius: 6.0)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        color.opacity(0.1),
                                        color]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .frame(width: proxy.size.width * CGFloat(progress.doubleValue))
                }.frame(height: lineWidth)
                if !labelHidden {
                    Text(progress, formatter: percentFormatter())
                        .font(.caption)
                }
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

let percentFormatter: () -> NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter
}

public struct ProgressCircle: View {
    let color: Color
    let lineWidth: CGFloat
    let labelHidden: Bool
    @Binding var progress: NSNumber
    
    public init(
        color: Color,
        lineWidth: CGFloat,
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
                Text(progress, formatter: percentFormatter())
                    .font(.caption)
            }
        }
    }
}



struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressBar(color: .blue, progress: .constant(0.3))
            ProgressCircle(
                color: .blue,
                lineWidth: 10.0,
                labelHidden: false,
                progress: .constant(0.4)
            )
        }.previewLayout(.sizeThatFits)
    }
}
