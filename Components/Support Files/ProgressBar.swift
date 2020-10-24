import SwiftUI
struct ProgressBar: View {
    let color: Color
    let lineWidth: CGFloat = 5.0
    @Binding var progress: NSNumber
    var body: some View {
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
                                        color.opacity(0.3),
                                        color]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .frame(width: proxy.size.width * CGFloat(progress.doubleValue))
                }.frame(height: lineWidth)
                Text(progress, formatter: percentFormatter())
                    .font(.caption)
            }
        }
    }
}

let percentFormatter: () -> NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter
}

extension Angle {}

struct ProgressCircle: View {
    let color: Color
    let lineWidth: CGFloat
    @Binding var progress: NSNumber
    var body: some View {
        Circle()
            .trim(from: .zero, to: CGFloat(progress.doubleValue))
            .stroke(color, style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            ))
            .rotationEffect(Angle(degrees: -90))
            .background(
                Circle()
                    .stroke(color.opacity(0.2), style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                    .rotationEffect(Angle(degrees: -90))
            ).overlay(
                Text(progress, formatter: percentFormatter())
                    .font(.caption)
            )
            .aspectRatio(contentMode: .fit)
            .padding(4.0)
    }
}



struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressBar(color: .blue, progress: .constant(0.3))
            ProgressCircle(
                color: .blue,
                lineWidth: 10.0,
                progress: .constant(0.4)
            )
        }.previewLayout(.sizeThatFits)
    }
}
