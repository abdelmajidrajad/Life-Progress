import SwiftUI
public struct SmartProgressBar: View {
    
    let maxSteps: Double
    let firstStep: Double
    let duration: Double
    let color: Color
    let lineWidth: CGFloat
    
    public init(
        maxSteps: Double,
        firstStep: Double,
        duration: Double,
        color: Color,
        lineWidth: CGFloat = 5.0
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.maxSteps = maxSteps
        self.firstStep = firstStep
        self.duration = duration
    }
    
    public var body: some View {
        
            HStack {
                Text("\(Int.zero)")
                    .foregroundColor(.white)
                    .font(.preferred(.py_caption2()))
                    .frame(width: .py_grid(5), height: .py_grid(5))
                    .background(
                        Circle().fill(color)
                    )
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: .py_grid(2))
                        .fill(color.opacity(0.2))
                    
                    GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: .py_grid(2))
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        color.opacity(0.5),
                                        color
                                    ]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing)
                        ).frame(
                            width: proxy.size.width * CGFloat(duration / maxSteps)
                        ).offset(x: CGFloat(firstStep / maxSteps) * proxy.size.width)
                        .animation(.interactiveSpring())
                    }
                }.frame(height: lineWidth)
                Text("\(Int(maxSteps))")
                    .foregroundColor(.white)
                    .font(.preferred(.py_caption2()))
                    .frame(width: .py_grid(5), height: .py_grid(5))
                    .background(
                        Circle().fill(color)
                    )
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct SmartProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        SmartProgressBar(
            maxSteps: 24,
            firstStep: 1,
            duration: 2,
            color: .green
        )
    }
}
