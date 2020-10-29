import SwiftUI

public enum ProgressStyle: Equatable {
    case bar, circle
    public mutating func toggle() {
        self = self == .bar ? .circle: .bar
    }
}

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
                        ).frame(
                            width: proxy.size.width * CGFloat(progress.doubleValue)
                        ).animation(.interactiveSpring())
                        
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



struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressBar(color: .blue, progress: .constant(0.1))
            ProgressCircle(
                color: .blue,
                lineWidth: 10.0,
                labelHidden: false,
                progress: .constant(0.4)
            )
        }.previewLayout(.sizeThatFits)
    }
}